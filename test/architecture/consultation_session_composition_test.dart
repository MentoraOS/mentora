import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/action_items/consultation_action_items_application_service.dart';
import 'package:mentora/application/assistant/consultation_assistant_application_service.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/consultation_memory/consultation_memory_application_service.dart';
import 'package:mentora/application/consultation_session/consultation_session_composition.dart';
import 'package:mentora/application/consultation_summary/consultation_summary_application_service.dart';
import 'package:mentora/application/recording/consultation_recording_application_service.dart';
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
import 'package:mentora/domain/recording/consultation_recording.dart';
import 'package:mentora/domain/recording/recording_provider.dart';
import 'package:mentora/domain/transcript/consultation_audio_stream.dart';
import 'package:mentora/domain/transcript/transcript_chunk.dart';
import 'package:mentora/domain/transcript/transcript_provider.dart';
import 'package:mentora/domain/translation/translated_transcript_chunk.dart';
import 'package:mentora/domain/translation/translation_provider.dart';
import 'package:mentora/domain/video_session/video_session_provider.dart';

void main() {
  group('ConsultationSession — an immutable bundle, nothing more', () {
    test('carries exactly the nine planned references, all final, with '
        'no state and no business method', () {
      final source = File(
        'lib/application/consultation_session/consultation_session.dart',
      ).readAsStringSync();

      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final String bookingId;',
        'final VideoSessionInfo liveSession;',
        'final RealtimeTranscriptApplicationService transcriptService;',
        'final RealtimeTranslationApplicationService translationService;',
        'final ConsultationAssistantApplicationService assistantService;',
        'final ConsultationActionItemsApplicationService actionItemsService;',
        'final RecordingOrchestrator recordingOrchestrator;',
        'final ConsultationSummaryApplicationService summaryService;',
        'final ConsultationAISessionOrchestrator aiSessionOrchestrator;',
      ]);
      // No state, no logic: only the const constructor, no methods.
      expect(source, isNot(contains('void ')));
      expect(source, isNot(contains('Future<')));
      expect(source, isNot(contains('=> ')));
      expect(source, contains('const ConsultationSession({'));
    });
  });

  group('ConsultationSessionComposition — build, assemble, return', () {
    test('one composition builds a complete consultation', () async {
      final composition = _composition();

      final consultation = composition.compose(
        bookingId: 'b1',
        liveSession: _liveSession(),
        audio: _AudioStream(),
        sourceLanguage: 'fr',
        targetLanguage: 'en',
      );

      expect(consultation.bookingId, 'b1');
      expect(consultation.liveSession.sessionId, 'mentora_consultation_b1');
      expect(consultation.transcriptService, isNotNull);
      expect(consultation.translationService, isNotNull);
      expect(consultation.assistantService, isNotNull);
      expect(consultation.actionItemsService, isNotNull);
      expect(consultation.recordingOrchestrator, isNotNull);
      expect(consultation.summaryService, isNotNull);
      expect(consultation.aiSessionOrchestrator, isNotNull);

      // The assembled coordinator actually coordinates the assembled
      // services (start-to-summary through the real contracts).
      await consultation.aiSessionOrchestrator.start();
      await consultation.aiSessionOrchestrator.stop();
    });

    test('the composition never starts anything by itself', () async {
      final log = <String>[];
      _composition(log: log).compose(
        bookingId: 'b1',
        liveSession: _liveSession(),
        audio: _AudioStream(),
      );

      // Building and assembling triggered no provider at all.
      expect(log, isEmpty);
    });

    test('the composition knows the application contracts only', () {
      final source = File(
        'lib/application/consultation_session/'
        'consultation_session_composition.dart',
      ).readAsStringSync();

      for (final forbidden in const [
        'AIGateway',
        'AIProvider',
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
        'infrastructure',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'the composition must not know $forbidden',
        );
      }
      // It never starts, stops, validates or computes.
      expect(source, isNot(contains('.start(')));
      expect(source, isNot(contains('.stop(')));
    });

    test('ONLY the composition constructs a ConsultationSession', () {
      const allowedConstruction = [
        'lib/application/consultation_session/consultation_session.dart',
        'lib/application/consultation_session/'
            'consultation_session_composition.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        if (entity.readAsStringSync().contains('ConsultationSession(') &&
            !allowedConstruction.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });

    test('the live screen receives ONE ConsultationSession instead of a '
        'multitude', () {
      final source = File(
        'lib/screens/live_consultation_screen.dart',
      ).readAsStringSync();

      expect(source, contains('final ConsultationSession? consultation;'));
      // The former multitude of per-surface parameters is gone.
      expect(source, isNot(contains('final TranslationStream?')));
      expect(source, isNot(contains('final AssistantStream?')));
      expect(source, isNot(contains('final ActionItemsStream?')));
      expect(source, isNot(contains('final RecordingOrchestrator?')));
      expect(
        source,
        isNot(contains('final ConsultationAISessionOrchestrator?')),
      );
    });
  });
}

VideoSessionInfo _liveSession() {
  return const VideoSessionInfo(
    sessionId: 'mentora_consultation_b1',
    participantIdentity: 'b1_client_client_1',
    role: VideoParticipantRole.client,
    serverUrl: 'wss://development-only.invalid/mentora',
    accessToken: 'token',
  );
}

ConsultationSessionComposition _composition({List<String>? log}) {
  final session = _Session('client_1');
  final events = log ?? <String>[];
  ConsultationMemoryApplicationService memory() {
    return ConsultationMemoryApplicationService(
      session: session,
      repository: _MemoryRepository(),
    );
  }

  return ConsultationSessionComposition(
    transcripts: RealtimeTranscriptApplicationService(
      session: session,
      provider: _TranscriptProvider(events),
    ),
    translations: RealtimeTranslationApplicationService(
      session: session,
      provider: _TranslationProvider(events),
    ),
    assistant: ConsultationAssistantApplicationService(
      session: session,
      memory: memory(),
      provider: _AssistantProvider(events),
    ),
    actionItems: ConsultationActionItemsApplicationService(
      session: session,
      memory: memory(),
      provider: _ActionItemsProvider(events),
    ),
    recording: ConsultationRecordingApplicationService(
      session: session,
      provider: _RecordingProviderFake(events),
    ),
    summaries: ConsultationSummaryApplicationService(
      session: session,
      memory: memory(),
      provider: _SummaryProvider(events),
      repository: _SummaryRepository(),
    ),
  );
}

final class _AudioStream implements ConsultationAudioStream {
  @override
  Stream<ConsultationAudioFrame> get frames => const Stream.empty();
}

final class _TranscriptProvider implements TranscriptProvider {
  _TranscriptProvider(this.log);

  final List<String> log;

  @override
  Future<TranscriptStream> start({
    required String sessionId,
    required ConsultationAudioStream audio,
  }) async {
    log.add('transcript.start');
    return _TranscriptStream(sessionId);
  }
}

final class _TranscriptStream implements TranscriptStream {
  _TranscriptStream(this.sessionId);

  @override
  final String sessionId;

  @override
  TranscriptStatus get status => TranscriptStatus.transcribing;

  @override
  Stream<TranscriptChunk> get chunks => const Stream.empty();

  @override
  Future<TranscriptResult> stop() async {
    return TranscriptResult(
      sessionId: sessionId,
      status: TranscriptStatus.stopped,
    );
  }
}

final class _TranslationProvider implements TranslationProvider {
  _TranslationProvider(this.log);

  final List<String> log;

  @override
  Future<TranslationStream> start({
    required Stream<TranscriptChunk> transcript,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    log.add('translation.start');
    return _TranslationStream();
  }
}

final class _TranslationStream implements TranslationStream {
  @override
  TranslationStatus get status => TranslationStatus.translating;

  @override
  Stream<TranslatedTranscriptChunk> get chunks => const Stream.empty();

  @override
  Future<TranslationResult> stop() async {
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
    return _AssistantStream(sessionId);
  }
}

final class _AssistantStream implements AssistantStream {
  _AssistantStream(this.sessionId);

  final String sessionId;

  @override
  AssistantStatus get status => AssistantStatus.assisting;

  @override
  Stream<AssistantSuggestion> get suggestions => const Stream.empty();

  @override
  Future<void> refresh(ConsultationMemory memory) async {}

  @override
  Future<AssistantResult> stop() async {
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
    return _ActionItemsStream(sessionId);
  }
}

final class _ActionItemsStream implements ActionItemsStream {
  _ActionItemsStream(this.sessionId);

  final String sessionId;

  @override
  ActionItemsStatus get status => ActionItemsStatus.proposing;

  @override
  Stream<ActionItem> get items => const Stream.empty();

  @override
  Future<void> refresh(ConsultationMemory memory) async {}

  @override
  Future<ActionItemsResult> stop() async {
    return ActionItemsResult(
      sessionId: sessionId,
      status: ActionItemsStatus.stopped,
    );
  }
}

final class _RecordingProviderFake implements RecordingProvider {
  _RecordingProviderFake(this.log);

  final List<String> log;

  @override
  Future<RecordingSession> start({required String bookingId}) async {
    log.add('recording.start');
    return _RecordingSessionFake(bookingId);
  }
}

final class _RecordingSessionFake implements RecordingSession {
  _RecordingSessionFake(this.bookingId);

  final String bookingId;

  @override
  ConsultationRecording get recording => ConsultationRecording(
    bookingId: bookingId,
    recordingId: 'rec_$bookingId',
    status: RecordingStatus.recording,
    createdAt: null,
  );

  @override
  Stream<ConsultationRecording> get updates => const Stream.empty();

  @override
  Future<RecordingResult> stop() async {
    return RecordingResult(recording: recording);
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
