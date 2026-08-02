import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/action_items/consultation_action_items_application_service.dart';
import 'package:mentora/application/assistant/consultation_assistant_application_service.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/consultation_memory/consultation_memory_application_service.dart';
import 'package:mentora/application/consultation_session/consultation_ai_session_orchestrator.dart';
import 'package:mentora/application/consultation_summary/consultation_summary_application_service.dart';
import 'package:mentora/application/transcript/realtime_transcript_application_service.dart';
import 'package:mentora/application/translation/realtime_translation_application_service.dart';
import 'package:mentora/domain/action_items/action_item.dart';
import 'package:mentora/domain/action_items/action_items_provider.dart';
import 'package:mentora/domain/assistant/assistant_provider.dart';
import 'package:mentora/domain/assistant/assistant_suggestion.dart';
import 'package:mentora/domain/consultation_memory/consultation_memory.dart';
import 'package:mentora/domain/consultation_memory/memory_repository.dart';
import 'package:mentora/domain/consultation_summary/ai_summary_provider.dart';
import 'package:mentora/domain/consultation_summary/consultation_summary.dart';
import 'package:mentora/domain/consultation_summary/summary_repository.dart';
import 'package:mentora/domain/transcript/consultation_audio_stream.dart';
import 'package:mentora/domain/transcript/transcript_chunk.dart';
import 'package:mentora/domain/transcript/transcript_provider.dart';
import 'package:mentora/domain/translation/translated_transcript_chunk.dart';
import 'package:mentora/domain/translation/translation_provider.dart';

void main() {
  group('ConsultationAISessionOrchestrator — order and coordination', () {
    test('starts in the exact order: transcript, translation, assistant, '
        'action items', () async {
      final harness = _Harness();
      final orchestrator = harness.build(withLanguages: true);

      await orchestrator.start();

      expect(harness.log, [
        'transcript.start',
        'translation.start',
        'assistant.start',
        'actionItems.start',
      ]);
      expect(orchestrator.transcript, isNotNull);
      expect(orchestrator.translation, isNotNull);
      expect(orchestrator.assistant, isNotNull);
      expect(orchestrator.actionItems, isNotNull);
    });

    test('without configured languages, translation never starts', () async {
      final harness = _Harness();
      final orchestrator = harness.build(withLanguages: false);

      await orchestrator.start();

      expect(harness.log, isNot(contains('translation.start')));
      expect(orchestrator.translation, isNull);
    });

    test('stops in REVERSE order and the summary is ALWAYS last', () async {
      final harness = _Harness();
      final orchestrator = harness.build(withLanguages: true);
      await orchestrator.start();
      harness.log.clear();

      await orchestrator.stop();

      expect(harness.log, [
        'actionItems.stop',
        'assistant.stop',
        'translation.stop',
        'transcript.stop',
        'summary.generate',
      ]);
    });

    test('a failed translation stops NOTHING else — fail closed locally, '
        'relayed, never masked', () async {
      final harness = _Harness(translationError: StateError('engine down'));
      final orchestrator = harness.build(withLanguages: true);
      final relayed = <Object>[];
      final subscription = orchestrator.failures.listen(relayed.add);

      await orchestrator.start();
      await orchestrator.stop();
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      // Transcript, assistant, action items and the summary all ran.
      expect(harness.log, [
        'transcript.start',
        'assistant.start',
        'actionItems.start',
        'actionItems.stop',
        'assistant.stop',
        'transcript.stop',
        'summary.generate',
      ]);
      expect(relayed, hasLength(1));
    });

    test('even a failed transcript still ends with the summary', () async {
      final harness = _Harness(transcriptError: StateError('audio down'));
      final orchestrator = harness.build(withLanguages: true);
      final relayed = <Object>[];
      final subscription = orchestrator.failures.listen(relayed.add);

      await orchestrator.start();
      await orchestrator.stop();
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(harness.log.last, 'summary.generate');
      // Translation depends on the transcript handle and was skipped.
      expect(harness.log, isNot(contains('translation.start')));
      expect(relayed, hasLength(1));
    });

    test('start and stop are one-shot — repeated calls are inert', () async {
      final harness = _Harness();
      final orchestrator = harness.build(withLanguages: false);

      await orchestrator.start();
      await orchestrator.start();
      await orchestrator.stop();
      await orchestrator.stop();

      expect(
        harness.log.where((entry) => entry == 'transcript.start'),
        hasLength(1),
      );
      expect(
        harness.log.where((entry) => entry == 'summary.generate'),
        hasLength(1),
      );
    });
  });

  group('Governance — a coordinator, nothing more', () {
    test('the coordinator knows only the application contracts', () {
      final source = File(
        'lib/application/consultation_session/'
        'consultation_ai_session_orchestrator.dart',
      ).readAsStringSync();

      for (final contract in const [
        'RealtimeTranscriptApplicationService',
        'RealtimeTranslationApplicationService',
        'ConsultationAssistantApplicationService',
        'ConsultationActionItemsApplicationService',
        'RecordingOrchestrator',
        'ConsultationSummaryApplicationService',
      ]) {
        expect(source, contains(contract));
      }
      for (final forbidden in const [
        'AIGateway',
        'openai',
        'OpenAI',
        'Deepgram',
        'deepgram',
        'Gemini',
        'gemini',
        'livekit',
        'LiveKit',
        'Firestore',
        'HttpClient',
        'Timer',
        'AIProvider',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'the coordinator must not know $forbidden',
        );
      }
    });

    test('only the live screen knows the coordinator', () {
      const allowedSurface = [
        'lib/application/consultation_session/'
            'consultation_ai_session_orchestrator.dart',
        'lib/screens/live_consultation_screen.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        if (entity
                .readAsStringSync()
                .contains('ConsultationAISessionOrchestrator') &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });

    test('the live screen only calls start at join and stop at leave', () {
      final source = File(
        'lib/screens/live_consultation_screen.dart',
      ).readAsStringSync();

      expect(source, contains('aiSession?.start()'));
      expect(source, contains('aiSession?.stop()'));
      // No other coordinator API is touched by the screen.
      expect(source, isNot(contains('aiSession?.transcript')));
      expect(source, isNot(contains('aiSession?.failures')));
    });
  });
}

/// Builds the coordinator over the REAL application services, each on a
/// fake provider that records into one shared ordered log.
final class _Harness {
  _Harness({this.transcriptError, this.translationError});

  final Object? transcriptError;
  final Object? translationError;
  final List<String> log = [];

  ConsultationAISessionOrchestrator build({required bool withLanguages}) {
    final session = _Session('client_1');
    return ConsultationAISessionOrchestrator(
      bookingId: 'b1',
      audio: _AudioStream(),
      sourceLanguage: withLanguages ? 'fr' : null,
      targetLanguage: withLanguages ? 'en' : null,
      transcripts: RealtimeTranscriptApplicationService(
        session: session,
        provider: _TranscriptProvider(log, error: transcriptError),
      ),
      translations: RealtimeTranslationApplicationService(
        session: session,
        provider: _TranslationProvider(log, error: translationError),
      ),
      assistant: ConsultationAssistantApplicationService(
        session: session,
        memory: _memoryService(session),
        provider: _AssistantProvider(log),
      ),
      actionItems: ConsultationActionItemsApplicationService(
        session: session,
        memory: _memoryService(session),
        provider: _ActionItemsProvider(log),
      ),
      summaries: ConsultationSummaryApplicationService(
        session: session,
        memory: _memoryService(session),
        provider: _SummaryProvider(log),
        repository: _SummaryRepository(),
      ),
    );
  }

  ConsultationMemoryApplicationService _memoryService(
    AuthenticationSession session,
  ) {
    return ConsultationMemoryApplicationService(
      session: session,
      repository: _MemoryRepository(),
    );
  }
}

final class _AudioStream implements ConsultationAudioStream {
  @override
  Stream<ConsultationAudioFrame> get frames => const Stream.empty();
}

final class _TranscriptProvider implements TranscriptProvider {
  _TranscriptProvider(this.log, {this.error});

  final List<String> log;
  final Object? error;

  @override
  Future<TranscriptStream> start({
    required String sessionId,
    required ConsultationAudioStream audio,
  }) async {
    if (error case final cause?) throw cause;
    log.add('transcript.start');
    return _TranscriptStream(log, sessionId);
  }
}

final class _TranscriptStream implements TranscriptStream {
  _TranscriptStream(this.log, this.sessionId);

  final List<String> log;

  @override
  final String sessionId;

  @override
  TranscriptStatus get status => TranscriptStatus.transcribing;

  @override
  Stream<TranscriptChunk> get chunks => const Stream.empty();

  @override
  Future<TranscriptResult> stop() async {
    log.add('transcript.stop');
    return TranscriptResult(
      sessionId: sessionId,
      status: TranscriptStatus.stopped,
    );
  }
}

final class _TranslationProvider implements TranslationProvider {
  _TranslationProvider(this.log, {this.error});

  final List<String> log;
  final Object? error;

  @override
  Future<TranslationStream> start({
    required Stream<TranscriptChunk> transcript,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (error case final cause?) throw cause;
    log.add('translation.start');
    return _TranslationStream(log);
  }
}

final class _TranslationStream implements TranslationStream {
  _TranslationStream(this.log);

  final List<String> log;

  @override
  TranslationStatus get status => TranslationStatus.translating;

  @override
  Stream<TranslatedTranscriptChunk> get chunks => const Stream.empty();

  @override
  Future<TranslationResult> stop() async {
    log.add('translation.stop');
    return const TranslationResult(status: TranslationStatus.stopped);
  }
}

final class _AssistantProvider implements AssistantProvider {
  _AssistantProvider(this.log);

  final List<String> log;

  @override
  Future<AssistantStream> start({
    required String sessionId,
    required ConsultationMemory memory,
  }) async {
    log.add('assistant.start');
    return _AssistantStream(log, sessionId);
  }
}

final class _AssistantStream implements AssistantStream {
  _AssistantStream(this.log, this.sessionId);

  final List<String> log;
  final String sessionId;

  @override
  AssistantStatus get status => AssistantStatus.assisting;

  @override
  Stream<AssistantSuggestion> get suggestions => const Stream.empty();

  @override
  Future<void> refresh(ConsultationMemory memory) async {}

  @override
  Future<AssistantResult> stop() async {
    log.add('assistant.stop');
    return AssistantResult(
      sessionId: sessionId,
      status: AssistantStatus.stopped,
    );
  }
}

final class _ActionItemsProvider implements ActionItemsProvider {
  _ActionItemsProvider(this.log);

  final List<String> log;

  @override
  Future<ActionItemsStream> start({
    required String sessionId,
    required ConsultationMemory memory,
  }) async {
    log.add('actionItems.start');
    return _ActionItemsStream(log, sessionId);
  }
}

final class _ActionItemsStream implements ActionItemsStream {
  _ActionItemsStream(this.log, this.sessionId);

  final List<String> log;
  final String sessionId;

  @override
  ActionItemsStatus get status => ActionItemsStatus.proposing;

  @override
  Stream<ActionItem> get items => const Stream.empty();

  @override
  Future<void> refresh(ConsultationMemory memory) async {}

  @override
  Future<ActionItemsResult> stop() async {
    log.add('actionItems.stop');
    return ActionItemsResult(
      sessionId: sessionId,
      status: ActionItemsStatus.stopped,
    );
  }
}

final class _SummaryProvider implements AISummaryProvider {
  _SummaryProvider(this.log);

  final List<String> log;

  @override
  Future<SummaryGenerationResult> generate({
    required String bookingId,
    required ConsultationMemory memory,
  }) async {
    log.add('summary.generate');
    return SummaryGenerationResult(
      summaryText: 'Résumé final.',
      provider: 'simulated',
      generatedAt: DateTime.utc(2026, 8, 2),
    );
  }
}

final class _SummaryRepository implements SummaryRepository {
  ConsultationSummary? _stored;

  @override
  Future<void> saveStatus({
    required String bookingId,
    required String userId,
    required SummaryStatus status,
    String? summaryText,
    String? provider,
  }) async {
    _stored = ConsultationSummary(
      bookingId: bookingId,
      status: status,
      summaryText: summaryText,
      provider: provider,
      createdAt: DateTime.utc(2026, 8, 2),
      updatedAt: DateTime.utc(2026, 8, 2),
    );
  }

  @override
  Future<ConsultationSummary?> findByBookingId({
    required String bookingId,
    required String userId,
  }) async => _stored;
}

final class _MemoryRepository implements MemoryRepository {
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
    return ConsultationMemory(
      bookingId: bookingId,
      entries: const [],
      createdAt: null,
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
