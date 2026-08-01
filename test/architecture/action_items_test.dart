import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/action_items/consultation_action_items_application_service.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/consultation_memory/consultation_memory_application_service.dart';
import 'package:mentora/domain/action_items/action_item.dart';
import 'package:mentora/domain/action_items/action_items_provider.dart';
import 'package:mentora/domain/ai_gateway/ai_gateway.dart';
import 'package:mentora/domain/ai_gateway/ai_provider.dart';
import 'package:mentora/domain/consultation_memory/consultation_memory.dart';
import 'package:mentora/domain/consultation_memory/memory_repository.dart';
import 'package:mentora/infrastructure/action_items/ai_action_items_provider.dart';
import 'package:mentora/infrastructure/ai_gateway/openai_action_items_adapter.dart';
import 'package:mentora/infrastructure/ai_gateway/openai_ai_provider.dart';

void main() {
  group('ConsultationActionItemsApplicationService', () {
    test('start reads ONLY the memory and attaches the proposal flux', () async {
      final memoryRepository = _MemoryRepository();
      final provider = _RecordingProvider();
      final service = _service(
        memoryRepository: memoryRepository,
        provider: provider,
      );

      final stream = await service.start('b1');

      expect(memoryRepository.reads, [('b1', 'client_1')]);
      expect(provider.started.single.$1, 'b1');
      expect(stream.status, ActionItemsStatus.proposing);
      expect(service.items(), isNotNull);
    });

    test('one live proposal flux at a time — fail closed', () async {
      final service = _service();
      await service.start('b1');

      await expectLater(
        service.start('b1'),
        throwsA(isA<ActionItemsAlreadyActiveFailure>()),
      );
    });

    test('refresh re-reads the memory and asks again', () async {
      final memoryRepository = _MemoryRepository();
      final provider = _RecordingProvider();
      final service = _service(
        memoryRepository: memoryRepository,
        provider: provider,
      );

      await service.start('b1');
      await service.refresh('b1');

      expect(memoryRepository.reads, hasLength(2));
      expect(provider.stream.refreshed, hasLength(1));
    });

    test('stop seals the flux and allows a fresh session', () async {
      final service = _service();
      await service.start('b1');

      final result = await service.stop();

      expect(result.sessionId, 'b1');
      expect(result.status, ActionItemsStatus.stopped);
      await service.start('b1');
    });

    test('an unauthenticated session fails typed before anything', () async {
      final memoryRepository = _MemoryRepository();
      final provider = _RecordingProvider();
      final service = ConsultationActionItemsApplicationService(
        session: _Session(null),
        memory: ConsultationMemoryApplicationService(
          session: _Session(null),
          repository: memoryRepository,
        ),
        provider: provider,
      );

      await expectLater(
        service.start('b1'),
        throwsA(isA<ActionItemsUnauthenticatedFailure>()),
      );
      expect(memoryRepository.reads, isEmpty);
      expect(provider.started, isEmpty);
    });

    test('a foreign user or unknown booking fails closed before the '
        'provider', () async {
      final provider = _RecordingProvider();
      final service = _service(
        memoryRepository: _MemoryRepository(
          error: const MemoryEntryNotFoundException(),
        ),
        provider: provider,
      );

      await expectLater(
        service.start('b1'),
        throwsA(isA<ActionItemsNotFoundFailure>()),
      );
      expect(provider.started, isEmpty);
    });
  });

  group('AIActionItemsProvider — the governed proposals', () {
    test('routes AITask.ACTION_ITEMS through the gateway and yields ONE '
        'action per line', () async {
      final gateway = _RecordingGateway(
        answers: [
          'HIGH;Envoyer le devis;Préparer et envoyer le devis discuté.\n'
              'NORMAL;Planifier un suivi;Proposer un créneau de suivi.\n'
              'une ligne invalide',
        ],
      );
      final provider = AIActionItemsProvider(gateway: gateway);

      final stream = await provider.start(
        sessionId: 'b1',
        memory: _memory(),
      );
      final received = <ActionItem>[];
      final subscription = stream.items.listen(received.add);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      final request = gateway.executed.single;
      expect(request.task, AITask.actionItems);
      expect(request.text, contains('chatMessage'));
      expect(request.text, contains('UNE'));

      // Individual actions — never a list packed into one string.
      expect(received, hasLength(2));
      expect(received.first.title, 'Envoyer le devis');
      expect(received.first.priority, ActionItemPriority.high);
      expect(received.last.title, 'Planifier un suivi');
      expect(received.last.priority, ActionItemPriority.normal);
      expect(stream.status, ActionItemsStatus.proposing);
    });

    test('invalid engine lines are rejected, never guessed', () {
      for (final line in const [
        'URGENT;Titre;Description',
        'du texte sans structure',
        'HIGH;;Description sans titre',
      ]) {
        expect(
          AIActionItemsProvider.parseLine(
            sessionId: 'b1',
            actionId: 'a1',
            line: line,
            createdAt: DateTime.utc(2026, 8, 1),
          ),
          isNull,
          reason: line,
        );
      }
    });

    test('the prompt frames proposals only and hides private notes', () {
      final prompt = AIActionItemsProvider.buildPrompt(_memory());

      expect(prompt, contains('tu ne décides rien'));
      expect(prompt, contains('privateNote'));
      expect(prompt, contains('(sans contenu)'));
      expect(prompt, isNot(contains('strictement privé')));
    });

    test('an engine failure marks the flux failed — never a fake '
        'proposal', () async {
      final gateway = _RecordingGateway(error: StateError('engine down'));
      final provider = AIActionItemsProvider(gateway: gateway);

      final stream = await provider.start(
        sessionId: 'b1',
        memory: _memory(),
      );
      final errors = <Object>[];
      final subscription = stream.items.listen((_) {}, onError: errors.add);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(errors, hasLength(1));
      expect(stream.status, ActionItemsStatus.failed);
    });
  });

  group('OpenAIActionItemsAdapter', () {
    test('delegates to the injected OpenAI relay and fails closed '
        'unconfigured', () async {
      const adapter = OpenAIActionItemsAdapter(
        configuration: OpenAIConfiguration(apiKey: ''),
      );

      expect(adapter.providerType, AIProviderType.openAI);
      await expectLater(
        adapter.execute(AIRequest(requestId: 'r1', text: 'prompt')),
        throwsA(isA<AIUnavailableFailure>()),
      );
      expect(await adapter.health(), isFalse);
    });
  });

  group('Governance — the action-items chain is the only route', () {
    test('the application service knows only the memory door and the '
        'provider port', () {
      final source = File(
        'lib/application/action_items/'
        'consultation_action_items_application_service.dart',
      ).readAsStringSync();

      expect(source, contains('ConsultationMemoryApplicationService'));
      expect(source, contains('ActionItemsProvider'));
      for (final forbidden in const [
        'AIGateway',
        'openai',
        'OpenAI',
        'HttpClient',
        'cloud_firestore',
        'conversation',
        'transcript',
        'translation',
        'booking_overview',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'the action-items service must not know $forbidden',
        );
      }
    });

    test('the action-items provider uses the gateway ONLY and persists '
        'nothing', () {
      final source = File(
        'lib/infrastructure/action_items/ai_action_items_provider.dart',
      ).readAsStringSync();

      expect(source, contains('AIGateway'));
      expect(source, contains('AITask.actionItems'));
      for (final forbidden in const [
        'openai',
        'OpenAI',
        'HttpClient',
        'cloud_firestore',
        'Firestore',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'the action-items provider must not know $forbidden',
        );
      }
    });

    test('an action carries exactly the six authorized facts and the '
        'three priorities', () {
      final source = File(
        'lib/domain/action_items/action_item.dart',
      ).readAsStringSync();

      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final String sessionId;',
        'final String actionId;',
        'final String title;',
        'final String description;',
        'final ActionItemPriority priority;',
        'final DateTime createdAt;',
      ]);
      expect(ActionItemPriority.values.map((value) => value.name).toList(), [
        'low',
        'normal',
        'high',
      ]);
    });

    test('the action-items surface is confined — no screen, no widget', () {
      const allowedSurface = [
        'lib/domain/action_items/action_item.dart',
        'lib/domain/action_items/action_items_provider.dart',
        'lib/application/action_items/'
            'consultation_action_items_application_service.dart',
        'lib/infrastructure/action_items/ai_action_items_provider.dart',
        'lib/infrastructure/ai_gateway/openai_action_items_adapter.dart',
        'lib/composition/mentora_composition_root.dart',
        'lib/composition/mentora_dependencies.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('ActionItemsProvider') ||
                source.contains('ActionItemsStream') ||
                source.contains(
                  'ConsultationActionItemsApplicationService',
                )) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });
  });
}

ConsultationMemory _memory() {
  return ConsultationMemory(
    bookingId: 'b1',
    entries: [
      MemoryEntry(
        id: 'e1',
        bookingId: 'b1',
        type: MemoryEntryType.chatMessage,
        createdAt: DateTime.utc(2026, 8, 1, 9),
        payload: const {'content': 'Bonjour'},
      ),
      MemoryEntry(
        id: 'e2',
        bookingId: 'b1',
        type: MemoryEntryType.privateNote,
        createdAt: DateTime.utc(2026, 8, 1, 10),
      ),
    ],
    createdAt: DateTime.utc(2026, 8, 1),
  );
}

ConsultationActionItemsApplicationService _service({
  _MemoryRepository? memoryRepository,
  _RecordingProvider? provider,
}) {
  final session = _Session('client_1');
  return ConsultationActionItemsApplicationService(
    session: session,
    memory: ConsultationMemoryApplicationService(
      session: session,
      repository: memoryRepository ?? _MemoryRepository(),
    ),
    provider: provider ?? _RecordingProvider(),
  );
}

final class _MemoryRepository implements MemoryRepository {
  _MemoryRepository({this.error});

  final Object? error;
  final List<(String, String)> reads = [];

  @override
  Future<void> record({
    required String bookingId,
    required String userId,
    required MemoryEntryType type,
    required Map<String, Object?> payload,
  }) async {}

  @override
  Future<ConsultationMemory> read({
    required String bookingId,
    required String userId,
  }) async {
    if (error case final cause?) throw cause;
    reads.add((bookingId, userId));
    return _memory();
  }
}

final class _RecordingProvider implements ActionItemsProvider {
  final List<(String, ConsultationMemory)> started = [];
  final _FakeStream stream = _FakeStream();

  @override
  Future<ActionItemsStream> start({
    required String sessionId,
    required ConsultationMemory memory,
  }) async {
    started.add((sessionId, memory));
    stream.sessionId = sessionId;
    return stream;
  }
}

final class _FakeStream implements ActionItemsStream {
  String sessionId = '';
  final List<ConsultationMemory> refreshed = [];

  @override
  ActionItemsStatus get status => ActionItemsStatus.proposing;

  @override
  Stream<ActionItem> get items => const Stream.empty();

  @override
  Future<void> refresh(ConsultationMemory memory) async {
    refreshed.add(memory);
  }

  @override
  Future<ActionItemsResult> stop() async {
    return ActionItemsResult(
      sessionId: sessionId,
      status: ActionItemsStatus.stopped,
    );
  }
}

final class _RecordingGateway implements AIGateway {
  _RecordingGateway({this.answers = const [], this.error});

  final List<String> answers;
  final Object? error;
  final List<AIRequest> executed = [];

  @override
  Future<AIResponse> execute(AIRequest request) async {
    if (error case final cause?) throw cause;
    executed.add(request);
    final answer = answers.length >= executed.length
        ? answers[executed.length - 1]
        : '';
    return AIResponse(
      providerType: AIProviderType.openAI,
      responseId: 'r_${executed.length}',
      status: AIResponseStatus.accepted,
      text: answer,
    );
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
