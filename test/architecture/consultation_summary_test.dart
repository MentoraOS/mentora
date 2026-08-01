import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/ai_gateway/ai_gateway_application_service.dart';
import 'package:mentora/application/consultation_memory/consultation_memory_application_service.dart';
import 'package:mentora/application/consultation_summary/consultation_summary_application_service.dart';
import 'package:mentora/domain/ai_gateway/ai_gateway.dart';
import 'package:mentora/domain/ai_gateway/ai_provider.dart';
import 'package:mentora/domain/consultation_memory/consultation_memory.dart';
import 'package:mentora/domain/consultation_memory/memory_repository.dart';
import 'package:mentora/domain/consultation_summary/ai_summary_provider.dart';
import 'package:mentora/domain/consultation_summary/consultation_summary.dart';
import 'package:mentora/domain/consultation_summary/summary_repository.dart';
import 'package:mentora/infrastructure/ai_gateway/openai_ai_provider.dart';
import 'package:mentora/infrastructure/consultation_summary/gateway_ai_summary_provider.dart';

void main() {
  group('ConsultationSummaryApplicationService', () {
    test('generation reads ONLY the memory and persists the text', () async {
      final memoryRepository = _MemoryRepository();
      final provider = _RecordingSummaryProvider();
      final states = _SummaryRepository();
      final service = _service(
        memoryRepository: memoryRepository,
        provider: provider,
        states: states,
      );

      final summary = await service.generate('b1');

      // The single business source: the memory, via its application door.
      expect(memoryRepository.reads, [('b1', 'client_1')]);
      expect(provider.generated.single.$1, 'b1');
      // Lifecycle persisted, then the text itself.
      expect(states.saved.map((entry) => entry.$3).toList(), [
        SummaryStatus.generating,
        SummaryStatus.available,
      ]);
      expect(states.saved.last.$4, 'Résumé de consultation.');
      expect(summary.status, SummaryStatus.available);
      expect(summary.summaryText, 'Résumé de consultation.');
    });

    test('a provider failure is persisted FAILED without text — never a '
        'fake success', () async {
      final states = _SummaryRepository();
      final service = _service(
        provider: _RecordingSummaryProvider(error: StateError('engine down')),
        states: states,
      );

      await expectLater(
        service.generate('b1'),
        throwsA(isA<SummaryUnavailableFailure>()),
      );
      expect(states.saved.map((entry) => entry.$3).toList(), [
        SummaryStatus.generating,
        SummaryStatus.failed,
      ]);
      expect(states.saved.last.$4, isNull);
    });

    test('a foreign user or unknown booking fails closed before the '
        'provider', () async {
      final provider = _RecordingSummaryProvider();
      final states = _SummaryRepository();
      final service = _service(
        memoryRepository: _MemoryRepository(
          error: const MemoryEntryNotFoundException(),
        ),
        provider: provider,
        states: states,
      );

      await expectLater(
        service.generate('b1'),
        throwsA(isA<SummaryNotFoundFailure>()),
      );
      expect(provider.generated, isEmpty);
      expect(states.saved, isEmpty);
    });

    test('a never-generated summary reads as NOT_GENERATED without text', () async {
      final summary = await _service().getSummary('b1');

      expect(summary.status, SummaryStatus.notGenerated);
      expect(summary.summaryText, isNull);
    });
  });

  group('GatewayAISummaryProvider — the real chain', () {
    test('routes AITask.summary through the AI gateway with the memory '
        'prompt', () async {
      final gateway = _RecordingGateway(
        response: const AIResponse(
          providerType: AIProviderType.openAI,
          responseId: 'r1',
          status: AIResponseStatus.accepted,
          text: '  Résumé généré.  ',
        ),
      );
      final provider = GatewayAISummaryProvider(gateway: gateway);

      final result = await provider.generate(
        bookingId: 'b1',
        memory: _memory(),
      );

      final request = gateway.executed.single;
      expect(request.task, AITask.summary);
      expect(request.requestId, 'summary_b1');
      // The prompt is built HERE, from the memory facts, verbatim.
      expect(request.text, contains('chatMessage'));
      expect(request.text, contains('Bonjour'));
      expect(request.text, contains('consultationCompleted'));
      expect(result.summaryText, 'Résumé généré.');
      expect(result.provider, 'openAI');
    });

    test('an empty or rejected engine answer fails closed', () async {
      for (final response in [
        const AIResponse(
          providerType: AIProviderType.openAI,
          responseId: 'r1',
          status: AIResponseStatus.accepted,
          text: '   ',
        ),
        const AIResponse(
          providerType: AIProviderType.openAI,
          responseId: 'r1',
          status: AIResponseStatus.rejected,
          text: 'ignored',
        ),
      ]) {
        final provider = GatewayAISummaryProvider(
          gateway: _RecordingGateway(response: response),
        );

        await expectLater(
          provider.generate(bookingId: 'b1', memory: _memory()),
          throwsA(anything),
        );
      }
    });

    test('the prompt renders private-note facts without any content', () {
      final prompt = GatewayAISummaryProvider.buildPrompt(_memory());

      expect(prompt, contains('privateNote'));
      expect(prompt, contains('(sans contenu)'));
      expect(prompt, isNot(contains('strictement privé')));
    });
  });

  group('AI gateway routing — AITask.SUMMARY', () {
    test('a summary request reaches the provider registered for the task', () async {
      final summaryEngine = _RecordingAIProvider();
      final fallback = _RecordingAIProvider();
      final gateway = AIGatewayApplicationService(
        session: _Session('client_1'),
        provider: fallback,
        taskProviders: {AITask.summary: summaryEngine},
      );

      await gateway.execute(
        AIRequest(requestId: 'r1', task: AITask.summary, text: 'prompt'),
      );
      await gateway.execute(AIRequest(requestId: 'r2', text: 'no task'));

      expect(summaryEngine.executed.single.requestId, 'r1');
      expect(fallback.executed.single.requestId, 'r2');
    });
  });

  group('OpenAI engine — configuration and confinement', () {
    test('an unconfigured engine fails closed before any network call', () async {
      const provider = OpenAIProvider(
        configuration: OpenAIConfiguration(apiKey: ''),
      );

      await expectLater(
        provider.execute(AIRequest(requestId: 'r1', text: 'prompt')),
        throwsA(isA<AIUnavailableFailure>()),
      );
      expect(await provider.health(), isFalse);
    });

    test('no key, secret or business module is hard-coded', () {
      final source = File(
        'lib/infrastructure/ai_gateway/openai_ai_provider.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('sk-')));
      // Configuration values are injected by the composition root.
      expect(source, isNot(contains('String.fromEnvironment')));
      // The engine relays text; it reads no business module.
      expect(source, isNot(contains('consultation_memory')));
      expect(source, isNot(contains('booking')));
      expect(source, isNot(contains('cloud_firestore')));
    });
  });

  group('Summary — adapter contract', () {
    final source = File(
      'lib/infrastructure/consultation_summary/firestore_summary_repository.dart',
    ).readAsStringSync();

    test('dedicated collection keyed by booking; text stored verbatim '
        'with the metadata', () {
      expect(source, contains("collection('consultation_summaries')"));
      expect(source, contains('_summaries.doc(bookingId)'));
      expect(source, contains('runTransaction'));
      expect(
        source,
        contains("data['clientId'] != userId && data['expertId'] != userId"),
      );
      expect(source, contains("'status': status.name,"));
      expect(source, contains("'summaryText': ?summaryText,"));
      expect(source, contains("'updatedAt': FieldValue.serverTimestamp()"));
      // The booking is read for the guard, never written.
      expect(source, isNot(contains('transaction.update')));
    });
  });

  group('ARC-SUM01 — the governed chain is the only route', () {
    test('the summary service knows the memory door and the provider port '
        '— never the gateway, never an engine', () {
      final source = File(
        'lib/application/consultation_summary/'
        'consultation_summary_application_service.dart',
      ).readAsStringSync();

      expect(source, contains('ConsultationMemoryApplicationService'));
      expect(source, contains('AISummaryProvider'));
      for (final forbidden in const [
        'AIGateway',
        'openai',
        'OpenAI',
        'conversation',
        'booking_overview',
        'cloud_firestore',
        'HttpClient',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'summary service must not touch $forbidden',
        );
      }
    });

    test('the summary infrastructure provider uses the gateway ONLY', () {
      final source = File(
        'lib/infrastructure/consultation_summary/'
        'gateway_ai_summary_provider.dart',
      ).readAsStringSync();

      expect(source, contains('AIGateway'));
      expect(source, contains('AITask.summary'));
      for (final forbidden in const [
        'openai',
        'OpenAI',
        'HttpClient',
        'http',
        'cloud_firestore',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'the summary provider must not touch $forbidden',
        );
      }
    });

    test('OpenAI is invisible outside its single Infrastructure adapter', () {
      const allowed = [
        'lib/infrastructure/ai_gateway/openai_ai_provider.dart',
        'lib/infrastructure/ai_gateway/openai_assistant_adapter.dart',
        'lib/composition/mentora_composition_root.dart',
        // The provider-type enum names the engine kind; it carries no SDK,
        // no endpoint and no secret.
        'lib/domain/ai_gateway/ai_provider.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        if (entity.readAsStringSync().toLowerCase().contains('openai') &&
            !allowed.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });

    test('the summary surface is confined', () {
      const allowedSurface = [
        'lib/domain/consultation_summary/consultation_summary.dart',
        'lib/domain/consultation_summary/ai_summary_provider.dart',
        'lib/domain/consultation_summary/summary_repository.dart',
        'lib/application/consultation_summary/'
            'consultation_summary_application_service.dart',
        'lib/infrastructure/consultation_summary/'
            'gateway_ai_summary_provider.dart',
        'lib/infrastructure/consultation_summary/firestore_summary_repository.dart',
        'lib/composition/mentora_composition_root.dart',
        'lib/composition/mentora_dependencies.dart',
        // The single authorized UI consumer (via the application door).
        'lib/widgets/consultation_summary_card.dart',
        'lib/main.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('SummaryProvider') ||
                source.contains('SummaryRepository') ||
                source.contains('ConsultationSummaryApplicationService')) &&
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
      MemoryEntry(
        id: 'e3',
        bookingId: 'b1',
        type: MemoryEntryType.consultationCompleted,
        createdAt: DateTime.utc(2026, 8, 1, 11),
      ),
    ],
    createdAt: DateTime.utc(2026, 8, 1),
  );
}

ConsultationSummaryApplicationService _service({
  _MemoryRepository? memoryRepository,
  _RecordingSummaryProvider? provider,
  _SummaryRepository? states,
}) {
  final session = _Session('client_1');
  return ConsultationSummaryApplicationService(
    session: session,
    memory: ConsultationMemoryApplicationService(
      session: session,
      repository: memoryRepository ?? _MemoryRepository(),
    ),
    provider: provider ?? _RecordingSummaryProvider(),
    repository: states ?? _SummaryRepository(),
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

final class _RecordingSummaryProvider implements AISummaryProvider {
  _RecordingSummaryProvider({this.error});

  final Object? error;
  final List<(String, ConsultationMemory)> generated = [];

  @override
  Future<SummaryGenerationResult> generate({
    required String bookingId,
    required ConsultationMemory memory,
  }) async {
    if (error case final cause?) throw cause;
    generated.add((bookingId, memory));
    return SummaryGenerationResult(
      summaryText: 'Résumé de consultation.',
      provider: 'openAI',
      generatedAt: DateTime.utc(2026, 8, 1, 12),
    );
  }
}

final class _SummaryRepository implements SummaryRepository {
  final List<(String, String, SummaryStatus, String?)> saved = [];

  @override
  Future<void> saveStatus({
    required String bookingId,
    required String userId,
    required SummaryStatus status,
    String? summaryText,
    String? provider,
  }) async {
    saved.add((bookingId, userId, status, summaryText));
  }

  @override
  Future<ConsultationSummary?> findByBookingId({
    required String bookingId,
    required String userId,
  }) async {
    if (saved.isEmpty) return null;
    return ConsultationSummary(
      bookingId: bookingId,
      status: saved.last.$3,
      summaryText: saved.last.$4,
      provider: null,
      createdAt: DateTime.utc(2026, 8, 1),
      updatedAt: DateTime.utc(2026, 8, 1),
    );
  }
}

final class _RecordingGateway implements AIGateway {
  _RecordingGateway({required this.response});

  final AIResponse response;
  final List<AIRequest> executed = [];

  @override
  Future<AIResponse> execute(AIRequest request) async {
    executed.add(request);
    return response;
  }
}

final class _RecordingAIProvider implements AIProvider {
  final List<AIRequest> executed = [];

  @override
  AIProviderType get providerType => AIProviderType.simulated;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    executed.add(request);
    return AIResponse(
      providerType: AIProviderType.simulated,
      responseId: 'simulated_${request.requestId}',
      status: AIResponseStatus.accepted,
    );
  }

  @override
  Future<bool> health() async => true;
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
