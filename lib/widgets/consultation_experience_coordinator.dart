import '../application/consultation_session/consultation_session.dart';
import 'consultation_experience.dart';
import 'consultation_experience_composition.dart';

/// Coordinates ONLY the visual experience of a consultation — and stays
/// invisible outside the experience platform.
///
/// At join it prepares the UI components (through the single experience
/// composition); at leave it releases them cleanly. It never modifies a
/// business service, never talks to a provider, the gateway, storage or
/// any engine: it knows the existing UI controllers alone.
final class ConsultationExperienceCoordinator {
  const ConsultationExperienceCoordinator({
    ConsultationExperienceComposition composition =
        const ConsultationExperienceComposition(),
  }) : _composition = composition;

  final ConsultationExperienceComposition _composition;

  /// Prepares the consultation's UI components for the join.
  ConsultationExperience join({
    required ConsultationSession consultationSession,
    required bool isExpert,
  }) {
    return _composition.compose(
      consultationSession: consultationSession,
      isExpert: isExpert,
    );
  }

  /// Releases the UI components cleanly at leave.
  void leave(ConsultationExperience experience) {
    experience.subtitlesController?.dispose();
    experience.assistantController?.dispose();
    experience.actionItemsController?.dispose();
    experience.recordingConsentController.dispose();
  }
}
