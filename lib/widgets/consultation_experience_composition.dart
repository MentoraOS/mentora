import '../application/consultation_session/consultation_session.dart';
import 'action_items_controller.dart';
import 'assistant_controller.dart';
import 'consultation_experience.dart';
import 'recording_consent_controller.dart';
import 'recording_indicator.dart';
import 'subtitle_controller.dart';

/// THE single composition of a consultation experience.
///
/// Exactly three verbs: build, assemble, return a
/// [ConsultationExperience] over an already-composed
/// [ConsultationSession]. It never starts, stops, transcribes,
/// translates, summarizes, records or computes: the AI session keeps
/// its own coordinator, each service keeps its own logic. The
/// expert-only surfaces (copilot, action review) are assembled ONLY for
/// an expert — the client never receives them (fail closed). Live AI
/// handles that do not exist yet simply compose to null.
final class ConsultationExperienceComposition {
  const ConsultationExperienceComposition();

  ConsultationExperience compose({
    required ConsultationSession consultationSession,
    required bool isExpert,
  }) {
    final orchestrator = consultationSession.aiSessionOrchestrator;

    SubtitleController? subtitles;
    if (orchestrator.translation case final translation?) {
      subtitles = SubtitleController(translation: translation);
    }

    AssistantController? assistant;
    ActionItemsController? actionItems;
    if (isExpert) {
      if (orchestrator.assistant case final copilot?) {
        assistant = AssistantController(assistant: copilot);
      }
      if (orchestrator.actionItems case final proposals?) {
        actionItems = ActionItemsController(actionItems: proposals);
      }
    }

    return ConsultationExperience(
      consultationSession: consultationSession,
      subtitlesController: subtitles,
      assistantController: assistant,
      actionItemsController: actionItems,
      recordingConsentController: RecordingConsentController(),
      recordingIndicator: RecordingIndicator(
        orchestrator: consultationSession.recordingOrchestrator,
      ),
      summaryController: consultationSession.summaryService,
    );
  }
}
