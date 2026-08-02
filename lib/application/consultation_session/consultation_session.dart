import '../../domain/video_session/video_session_provider.dart';
import '../action_items/consultation_action_items_application_service.dart';
import '../assistant/consultation_assistant_application_service.dart';
import '../consultation_summary/consultation_summary_application_service.dart';
import '../recording/recording_orchestrator.dart';
import '../transcript/realtime_transcript_application_service.dart';
import '../translation/realtime_translation_application_service.dart';
import 'consultation_ai_session_orchestrator.dart';

/// One fully assembled consultation — an immutable BUNDLE of references
/// that already exist, and nothing more.
///
/// No state, no logic, no business method: the session orchestrator
/// keeps coordinating, each service keeps owning its own logic; this
/// object only carries them together so the live screen receives ONE
/// thing instead of a multitude. GOVERNANCE: only
/// ConsultationSessionComposition may construct it.
final class ConsultationSession {
  final String bookingId;
  final VideoSessionInfo liveSession;
  final RealtimeTranscriptApplicationService transcriptService;
  final RealtimeTranslationApplicationService translationService;
  final ConsultationAssistantApplicationService assistantService;
  final ConsultationActionItemsApplicationService actionItemsService;
  final RecordingOrchestrator recordingOrchestrator;
  final ConsultationSummaryApplicationService summaryService;
  final ConsultationAISessionOrchestrator aiSessionOrchestrator;

  const ConsultationSession({
    required this.bookingId,
    required this.liveSession,
    required this.transcriptService,
    required this.translationService,
    required this.assistantService,
    required this.actionItemsService,
    required this.recordingOrchestrator,
    required this.summaryService,
    required this.aiSessionOrchestrator,
  });
}
