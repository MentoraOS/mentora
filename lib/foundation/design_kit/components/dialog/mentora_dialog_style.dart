import 'package:flutter/foundation.dart';

import '../../registry/semantic_roles.dart';

/// The eight official dialog variants — the only overlay vocabulary
/// the business screens will ever speak. No screen ever touches
/// AlertDialog, Dialog, SimpleDialog or showDialog.
enum MentoraDialogVariant {
  information,
  success,
  warning,
  critical,
  confirmation,
  decision,
  progress,
  custom,
}

/// The elevation MEANING a variant carries. A dialog is one of the
/// rare components that legitimately carries one: it passes in front
/// of the scene. An aparté consults and returns; a decision is an
/// enclosure that must be answered.
///
/// This mapping is the single truth: the adapter reads it to obtain
/// the expression, the service reads it to know whether stepping back
/// exists at all.
ElevationMeaning elevationMeaningOf(MentoraDialogVariant variant) {
  switch (variant) {
    case MentoraDialogVariant.confirmation:
    case MentoraDialogVariant.decision:
    case MentoraDialogVariant.critical:
    case MentoraDialogVariant.progress:
      return ElevationMeaning.decision;
    case MentoraDialogVariant.information:
    case MentoraDialogVariant.success:
    case MentoraDialogVariant.warning:
    case MentoraDialogVariant.custom:
      return ElevationMeaning.aparte;
  }
}

/// The eight official states — no more. Four belong to the layer's
/// life (owned by the host), four to the exchange itself (announced
/// by the application through its controller).
enum MentoraDialogState {
  closed,
  opening,
  opened,
  waiting,
  processing,
  success,
  error,
  closing,
}

/// What the application announces about the exchange while the layer
/// is open. `waiting` is the resting phase: the dialog waits for the
/// person — it never hurries them.
enum MentoraDialogPhase { waiting, processing, success, error }

/// Drives the exchange of the open dialog. The application announces;
/// the dialog expresses. One controller serves exactly one dialog.
final class MentoraDialogController extends ChangeNotifier {
  MentoraDialogPhase _phase = MentoraDialogPhase.waiting;

  MentoraDialogPhase get phase => _phase;

  void beginProcessing() => _update(MentoraDialogPhase.processing);

  void showSuccess() => _update(MentoraDialogPhase.success);

  void showError() => _update(MentoraDialogPhase.error);

  void reset() => _update(MentoraDialogPhase.waiting);

  void _update(MentoraDialogPhase next) {
    if (next == _phase) return;
    _phase = next;
    notifyListeners();
  }
}
