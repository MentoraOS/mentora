import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/action_items/consultation_action_items_application_service.dart';
import 'package:mentora/application/assistant/consultation_assistant_application_service.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/consultation_memory/consultation_memory_application_service.dart';
import 'package:mentora/application/consultation_session/consultation_session.dart';
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
import 'package:mentora/widgets/consultation_experience_composition.dart';
import 'package:mentora/widgets/consultation_experience_coordinator.dart';
import 'package:mentora/widgets/recording_indicator.dart';

void main() {
  group('ConsultationExperience — an immutable bundle, nothing more', () {
    test('carries exactly the seven planned references, all final, with '
        'no method and no business state', () {
      final source = File(
        'lib/widgets/consultation_experience.dart',
      ).readAsStringSync();

      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final ConsultationSession consultationSession;',
        'final SubtitleController? subtitlesController;',
        'final AssistantController? assistantController;',
        'final ActionItemsController? actionItemsController;',
        'final RecordingConsentController recordingConsentController;',
        'final Widget recordingIndicator;',
        'final ConsultationSummaryApplicationService summaryController;',
      ]);
      // No logic, no method: only the const constructor.
      expect(source, isNot(contains('void ')));
      expect(source, isNot(contains('Future<')));
      expect(source, isNot(contains('=> ')));
      expect(source, contains('const ConsultationExperience({'));
    });
  });

  group('ConsultationExperienceComposition — build, assemble, return', () {
    test('composes the full experience for an expert', () async {
      final consultation = _consultation();
      await consultation.aiSessionOrchestrator.start();

      final experience = const ConsultationExperienceComposition().compose(
        consultationSession: consultation,
        isExpert: true,
      );

      expect(experience.consultationSession, same(consultation));
      expect(experience.subtitlesController, isNotNull);
      expect(experience.assistantController, isNotNull);
      expect(experience.actionItemsController, isNotNull);
      expect(experience.recordingConsentController, isNotNull);
      expect(experience.recordingIndicator, isA<RecordingIndicator>());
      expect(
        experience.summaryController,
        same(consultation.summaryService),
      );

      const ConsultationExperienceCoordinator().leave(experience);
    });

    test('the client NEVER receives the expert-only surfaces — fail '
        'closed', () async {
      final consultation = _consultation();
      await consultation.aiSessionOrchestrator.start();

      final experience = const ConsultationExperienceComposition().compose(
        consultationSession: consultation,
        isExpert: false,
      );

      expect(experience.assistantController, isNull);
      expect(experience.actionItemsController, isNull);
      expect(experience.subtitlesController, isNotNull);

      const ConsultationExperienceCoordinator().leave(experience);
    });

    test('AI handles that do not exist yet compose to null — nothing '
        'invented', () {
      final experience = const ConsultationExperienceComposition().compose(
        consultationSession: _consultation(),
        isExpert: true,
      );

      expect(experience.subtitlesController, isNull);
      expect(experience.assistantController, isNull);
      expect(experience.actionItemsController, isNull);

      const ConsultationExperienceCoordinator().leave(experience);
    });
  });

  group('ConsultationExperienceCoordinator — prepare and release only', () {
    test('join prepares through the single composition; leave releases '
        'cleanly', () async {
      final consultation = _consultation();
      await consultation.aiSessionOrchestrator.start();
      const coordinator = ConsultationExperienceCoordinator();

      final experience = coordinator.join(
        consultationSession: consultation,
        isExpert: true,
      );
      expect(experience.subtitlesController, isNotNull);

      coordinator.leave(experience);
      // Released controllers notify no more.
      expect(
        () => experience.recordingConsentController.acceptClient(),
        throwsFlutterError,
      );
    });

    test('the coordinator contains zero business logic and knows no '
        'engine, provider, gateway or storage', () {
      for (final path in const [
        'lib/widgets/consultation_experience_coordinator.dart',
        'lib/widgets/consultation_experience_composition.dart',
        'lib/widgets/consultation_experience.dart',
      ]) {
        final source = File(path).readAsStringSync();
        for (final forbidden in const [
          'AIGateway',
          'AIProvider',
          'openai',
          'OpenAI',
          'Deepgram',
          'Gemini',
          'livekit',
          'LiveKit',
          'Firestore',
          'HttpClient',
          'infrastructure',
        ]) {
          expect(
            source,
            isNot(contains(forbidden)),
            reason: '$path must not know $forbidden',
          );
        }
      }
      final coordinator = File(
        'lib/widgets/consultation_experience_coordinator.dart',
      ).readAsStringSync();
      // It never starts or stops anything business-side.
      expect(coordinator, isNot(contains('.start(')));
      expect(coordinator, isNot(contains('aiSessionOrchestrator')));
    });
  });

  group('Governance — the experience platform stays sealed', () {
    test('only the live screen knows ConsultationExperience, only the '
        'composition constructs it, the coordinator stays internal', () {
      const allowedKnowledge = [
        'lib/widgets/consultation_experience.dart',
        'lib/widgets/consultation_experience_composition.dart',
        'lib/widgets/consultation_experience_coordinator.dart',
        'lib/screens/live_consultation_screen.dart',
      ];
      const allowedConstruction = [
        'lib/widgets/consultation_experience.dart',
        'lib/widgets/consultation_experience_composition.dart',
      ];
      const allowedCoordinator = [
        'lib/widgets/consultation_experience_coordinator.dart',
      ];

      final knowledgeOffenders = <String>[];
      final constructionOffenders = <String>[];
      final coordinatorOffenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if (source.contains('ConsultationExperience') &&
            !allowedKnowledge.contains(normalized)) {
          knowledgeOffenders.add(normalized);
        }
        if (source.contains('ConsultationExperience(') &&
            !allowedConstruction.contains(normalized)) {
          constructionOffenders.add(normalized);
        }
        if (source.contains('ConsultationExperienceCoordinator') &&
            !allowedCoordinator.contains(normalized)) {
          coordinatorOffenders.add(normalized);
        }
      }
      expect(knowledgeOffenders, isEmpty);
      expect(constructionOffenders, isEmpty);
      expect(coordinatorOffenders, isEmpty);
    });

    test('the live screen receives the experience and only reads it', () {
      final source = File(
        'lib/screens/live_consultation_screen.dart',
      ).readAsStringSync();

      expect(source, contains('final ConsultationExperience? experience;'));
      // Ownership: the platform releases what it built.
      expect(source, contains('_ownsControllers = false'));
      expect(source, isNot(contains('ConsultationExperienceComposition')));
    });
  });
}

ConsultationSession _consultation() {
  final session = _Session('client_1');
  ConsultationMemoryApplicationService memory() {
    return ConsultationMemoryApplicationService(
      session: session,
      repository: _MemoryRepository(),
    );
  }

  return ConsultationSessionComposition(
    transcripts: RealtimeTranscriptApplicationService(
      session: session,
      provider: _TranscriptProvider(),
    ),
    translations: RealtimeTranslationApplicationService(
      session: session,
      provider: _TranslationProvider(),
    ),
    assistant: ConsultationAssistantApplicationService(
      session: session,
      memory: memory(),
      provider: _AssistantProvider(),
    ),
    actionItems: ConsultationActionItemsApplicationService(
      session: session,
      memory: memory(),
      provider: _ActionItemsProvider(),
    ),
    recording: ConsultationRecordingApplicationService(
      session: session,
      provider: _RecordingProviderFake(),
    ),
    summaries: ConsultationSummaryApplicationService(
      session: session,
      memory: memory(),
      provider: _SummaryProvider(),
      repository: _SummaryRepository(),
    ),
  ).compose(
    bookingId: 'b1',
    liveSession: const VideoSessionInfo(
      sessionId: 'mentora_consultation_b1',
      participantIdentity: 'b1_client_client_1',
      role: VideoParticipantRole.client,
      serverUrl: 'wss://development-only.invalid/mentora',
      accessToken: 'token',
    ),
    audio: _AudioStream(),
    sourceLanguage: 'fr',
    targetLanguage: 'en',
  );
}

final class _AudioStream implements ConsultationAudioStream {
  @override
  Stream<ConsultationAudioFrame> get frames => const Stream.empty();
}

final class _TranscriptProvider implements TranscriptProvider {
  @override
  Future<TranscriptStream> start({
    required String sessionId,
    required ConsultationAudioStream audio,
  }) async {
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
  @override
  Future<TranslationStream> start({
    required Stream<TranscriptChunk> transcript,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
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
  @override
  Future<AssistantStream> start({
    required String sessionId,
    required ConsultationMemory memory,
  }) async {
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
  @override
  Future<ActionItemsStream> start({
    required String sessionId,
    required ConsultationMemory memory,
  }) async {
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
  @override
  Future<RecordingSession> start({required String bookingId}) async {
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
  @override
  Future<SummaryGenerationResult> generate({
    required String bookingId,
    required ConsultationMemory memory,
  }) async {
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
