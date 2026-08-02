import '../../domain/transcript/consultation_audio_stream.dart';
import '../../domain/video_session/video_session_provider.dart';
import '../action_items/consultation_action_items_application_service.dart';
import '../assistant/consultation_assistant_application_service.dart';
import '../consultation_summary/consultation_summary_application_service.dart';
import '../recording/consultation_recording_application_service.dart';
import '../recording/recording_orchestrator.dart';
import '../transcript/realtime_transcript_application_service.dart';
import '../translation/realtime_translation_application_service.dart';
import 'consultation_ai_session_orchestrator.dart';
import 'consultation_session.dart';

/// THE single composition of a Mentora consultation.
///
/// Exactly three verbs: build, assemble, return a [ConsultationSession].
/// It never starts, stops, validates, computes, routes, translates,
/// transcribes or summarizes — the session orchestrator keeps
/// coordinating and this composition only constructs. It knows the
/// application contracts alone: never a provider, an adapter, an
/// engine, the media vendor SDK, storage or the network. Future
/// compositions — web, desktop, mobile, server, multi-region,
/// distributed, integration-test, simulation, offline — are siblings of
/// this class assembling the same contracts differently.
final class ConsultationSessionComposition {
  const ConsultationSessionComposition({
    required RealtimeTranscriptApplicationService transcripts,
    required RealtimeTranslationApplicationService translations,
    required ConsultationAssistantApplicationService assistant,
    required ConsultationActionItemsApplicationService actionItems,
    required ConsultationRecordingApplicationService recording,
    required ConsultationSummaryApplicationService summaries,
  }) : _transcripts = transcripts,
       _translations = translations,
       _assistant = assistant,
       _actionItems = actionItems,
       _recording = recording,
       _summaries = summaries;

  final RealtimeTranscriptApplicationService _transcripts;
  final RealtimeTranslationApplicationService _translations;
  final ConsultationAssistantApplicationService _assistant;
  final ConsultationActionItemsApplicationService _actionItems;
  final ConsultationRecordingApplicationService _recording;
  final ConsultationSummaryApplicationService _summaries;

  /// Builds, assembles and returns one consultation. The audio transport
  /// arrives as its domain contract (the caller owning the live room
  /// provides it); languages are injected values.
  ConsultationSession compose({
    required String bookingId,
    required VideoSessionInfo liveSession,
    required ConsultationAudioStream audio,
    String? sourceLanguage,
    String? targetLanguage,
  }) {
    final recordingOrchestrator = RecordingOrchestrator(
      recording: _recording,
      bookingId: bookingId,
    );

    final aiSessionOrchestrator = ConsultationAISessionOrchestrator(
      bookingId: bookingId,
      audio: audio,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      transcripts: _transcripts,
      translations: _translations,
      assistant: _assistant,
      actionItems: _actionItems,
      recording: recordingOrchestrator,
      summaries: _summaries,
    );

    return ConsultationSession(
      bookingId: bookingId,
      liveSession: liveSession,
      transcriptService: _transcripts,
      translationService: _translations,
      assistantService: _assistant,
      actionItemsService: _actionItems,
      recordingOrchestrator: recordingOrchestrator,
      summaryService: _summaries,
      aiSessionOrchestrator: aiSessionOrchestrator,
    );
  }
}
