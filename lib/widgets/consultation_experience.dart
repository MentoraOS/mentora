import 'package:flutter/material.dart';

import '../application/consultation_session/consultation_session.dart';
import '../application/consultation_summary/consultation_summary_application_service.dart';
import 'action_items_controller.dart';
import 'assistant_controller.dart';
import 'recording_consent_controller.dart';
import 'subtitle_controller.dart';

/// One fully assembled consultation EXPERIENCE — an immutable bundle of
/// references that already exist, and nothing more.
///
/// The experience platform is independent of the AI platform: this
/// object carries the UI-side controllers and surfaces of a
/// consultation, decides nothing, holds no business state and exposes
/// no method. GOVERNANCE: only ConsultationExperienceComposition may
/// construct it, and only the live screen may know it. Future UX
/// innovations — onboarding, pre-consultation checklist, intelligent
/// briefing, collaborative whiteboard, screen sharing, enriched notes,
/// multi-screen sync, contextual widgets, interface personalization,
/// web/desktop/mobile experiences, advanced accessibility — join this
/// bundle as new references, never as logic.
final class ConsultationExperience {
  final ConsultationSession consultationSession;
  final SubtitleController? subtitlesController;
  final AssistantController? assistantController;
  final ActionItemsController? actionItemsController;
  final RecordingConsentController recordingConsentController;

  /// The prebuilt, reusable REC indicator surface.
  final Widget recordingIndicator;

  /// The summary's application door — the experience only carries the
  /// reference; the service keeps owning its logic.
  final ConsultationSummaryApplicationService summaryController;

  const ConsultationExperience({
    required this.consultationSession,
    required this.subtitlesController,
    required this.assistantController,
    required this.actionItemsController,
    required this.recordingConsentController,
    required this.recordingIndicator,
    required this.summaryController,
  });
}
