import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/assistant/consultation_assistant_application_service.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/consultation_memory/consultation_memory_application_service.dart';
import 'package:mentora/domain/ai_gateway/ai_gateway.dart';
import 'package:mentora/domain/ai_gateway/ai_provider.dart';
import 'package:mentora/domain/assistant/assistant_provider.dart';
import 'package:mentora/domain/assistant/assistant_suggestion.dart';
import 'package:mentora/domain/consultation_memory/consultation_memory.dart';
import 'package:mentora/domain/consultation_memory/memory_repository.dart';
import 'package:mentora/infrastructure/assistant/ai_assistant_provider.dart';
import 'package:mentora/infrastructure/ai_gateway/openai_assistant_adapter.dart';
import 'package:mentora/infrastructure/ai_gateway/openai_ai_provider.dart';

void main() {
  group('ConsultationAssistantApplicationService', () {
    test('start reads ONLY the memory and attaches the copilot', () async {
      final memoryRepository = _MemoryRepository();
      final provider = _RecordingProvider();
      final service = _service(
        memoryRepository: memoryRepository,
        provider: provider,
      );

      final stream = await service.start('b1');

      expect(memoryRepository.reads, [('b1', 'client_1')]);
      expect(provider.started.single.$1, 'b1');
      expect(provider.started.single.$2.bookingId, 'b1');
      expect(stream.status, AssistantStatus.assisting);
      expect(service.suggestions(), isNotNull);
    });

    test('one live copilot at a time — fail closed', () async {
      final service = _service();
      await service.start('b1');

      await expectLater(
        service.start('b1'),
        throwsA(isA<AssistantAlreadyActiveFailure>()),
      );
    });

    test('refresh re-reads the memory and asks the copilot again', () async {
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

    test('stop seals the copilot and allows a fresh session', () async {
      final service = _service();
      await service.start('b1');

      final result = await service.stop();

      expect(result.sessionId, 'b1');
      expect(result.status, AssistantStatus.stopped);
      await service.start('b1');
    });

    test('an unauthenticated session fails typed before anything', () async {
      final memoryRepository = _MemoryRepository();
      final provider = _RecordingProvider();
      final service = ConsultationAssistantApplicationService(
        session: _Session(null),
        memory: ConsultationMemoryApplicationService(
          session: _Session(null),
          repository: memoryRepository,
        ),
        provider: provider,
      );

      await expectLater(
        service.start('b1'),
        throwsA(isA<AssistantUnauthenticatedFailure>()),
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
        throwsA(isA<AssistantNotFoundFailure>()),
      );
      expect(provider.started, isEmpty);
    });

    test('suggestions and stop without an active copilot fail closed', () async {
      final service = _service();

      expect(
        () => service.suggestions(),
        throwsA(isA<AssistantUnavailableFailure>()),
      );
      await expectLater(
        service.stop(),
        throwsA(isA<AssistantUnavailableFailure>()),
      );
    });
  });

  group('AIAssistantProvider — the governed copilot', () {
    test('routes AITask.assistant through the gateway and parses the '
        'suggestion protocol', () async {
      final gateway = _RecordingGateway(
        answers: [
          'HIGH;Point non abordé;Le budget n’a pas été discuté.\n'
              'NORMAL;Question utile;Demander les délais souhaités.\n'
              'ligne inexploitable sans structure',
        ],
      );
      final provider = AIAssistantProvider(gateway: gateway);

      final stream = await provider.start(
        sessionId: 'b1',
        memory: _memory(),
      );
      final received = <AssistantSuggestion>[];
      final subscription = stream.suggestions.listen(received.add);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      final request = gateway.executed.single;
      expect(request.task, AITask.assistant);
      expect(request.text, contains('chatMessage'));
      expect(request.text, contains('copilote'));

      expect(received, hasLength(2));
      expect(received.first.priority, AssistantPriority.high);
      expect(received.first.title, 'Point non abordé');
      expect(received.first.content, 'Le budget n’a pas été discuté.');
      expect(received.last.priority, AssistantPriority.normal);
      expect(stream.status, AssistantStatus.assisting);
    });

    test('the prompt renders private-note facts without any content and '
        'frames the copilot, never a decision-maker', () {
      final prompt = AIAssistantProvider.buildPrompt(_memory());

      expect(prompt, contains('privateNote'));
      expect(prompt, contains('(sans contenu)'));
      expect(prompt, isNot(contains('strictement privé')));
      expect(prompt, contains('tu ne décides jamais'));
    });

    test('unparseable engine output is dropped, never guessed', () {
      final suggestion = AIAssistantProvider.parseLine(
        sessionId: 'b1',
        suggestionId: 's1',
        line: 'URGENT;Titre;Contenu',
        createdAt: DateTime.utc(2026, 8, 1),
      );

      expect(suggestion, isNull);
      expect(
        AIAssistantProvider.parseLine(
          sessionId: 'b1',
          suggestionId: 's1',
          line: 'du texte sans structure',
          createdAt: DateTime.utc(2026, 8, 1),
        ),
        isNull,
      );
    });

    test('an engine failure marks the copilot failed — never a fake '
        'suggestion', () async {
      final gateway = _RecordingGateway(error: StateError('engine down'));
      final provider = AIAssistantProvider(gateway: gateway);

      final stream = await provider.start(
        sessionId: 'b1',
        memory: _memory(),
      );
      final errors = <Object>[];
      final subscription = stream.suggestions.listen(
        (_) {},
        onError: errors.add,
      );
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(errors, hasLength(1));
      expect(stream.status, AssistantStatus.failed);
    });
  });

  group('OpenAIAssistantAdapter', () {
    test('delegates to the injected OpenAI relay and fails closed '
        'unconfigured', () async {
      const adapter = OpenAIAssistantAdapter(
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

  group('Governance — the copilot chain is the only route', () {
    test('the application service knows only the memory door and the '
        'provider port', () {
      final source = File(
        'lib/application/assistant/'
        'consultation_assistant_application_service.dart',
      ).readAsStringSync();

      expect(source, contains('ConsultationMemoryApplicationService'));
      expect(source, contains('AssistantProvider'));
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
          reason: 'the assistant service must not know $forbidden',
        );
      }
    });

    test('the assistant provider uses the gateway ONLY and persists '
        'nothing', () {
      final source = File(
        'lib/infrastructure/assistant/ai_assistant_provider.dart',
      ).readAsStringSync();

      expect(source, contains('AIGateway'));
      expect(source, contains('AITask.assistant'));
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
          reason: 'the assistant provider must not know $forbidden',
        );
      }
    });

    test('a suggestion carries exactly the six authorized facts and the '
        'three priorities', () {
      final source = File(
        'lib/domain/assistant/assistant_suggestion.dart',
      ).readAsStringSync();

      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final String sessionId;',
        'final String suggestionId;',
        'final String title;',
        'final String content;',
        'final AssistantPriority priority;',
        'final DateTime createdAt;',
      ]);
      expect(AssistantPriority.values.map((value) => value.name).toList(), [
        'low',
        'normal',
        'high',
      ]);
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

ConsultationAssistantApplicationService _service({
  _MemoryRepository? memoryRepository,
  _RecordingProvider? provider,
}) {
  final session = _Session('client_1');
  return ConsultationAssistantApplicationService(
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

final class _RecordingProvider implements AssistantProvider {
  final List<(String, ConsultationMemory)> started = [];
  final _FakeStream stream = _FakeStream();

  @override
  Future<AssistantStream> start({
    required String sessionId,
    required ConsultationMemory memory,
  }) async {
    started.add((sessionId, memory));
    stream.sessionId = sessionId;
    return stream;
  }
}

final class _FakeStream implements AssistantStream {
  String sessionId = '';
  final List<ConsultationMemory> refreshed = [];

  @override
  AssistantStatus get status => AssistantStatus.assisting;

  @override
  Stream<AssistantSuggestion> get suggestions => const Stream.empty();

  @override
  Future<void> refresh(ConsultationMemory memory) async {
    refreshed.add(memory);
  }

  @override
  Future<AssistantResult> stop() async {
    return AssistantResult(
      sessionId: sessionId,
      status: AssistantStatus.stopped,
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
