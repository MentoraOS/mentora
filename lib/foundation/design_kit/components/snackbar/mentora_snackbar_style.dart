import 'package:flutter/foundation.dart';

import '../../registry/semantic_roles.dart';
import '../../tokens/snackbar_tokens.dart';

/// The eight official message variants — the only transient-signal
/// vocabulary the business screens will ever speak. No screen ever
/// touches the framework's snackbar, its messenger, or any of its
/// imperative openings.
enum MentoraSnackbarVariant {
  information,
  success,
  warning,
  error,
  offline,
  sync,
  processing,
  custom,
}

/// The six official states — no more. `expiring` is a message leaving
/// on its own; `dismissed` is a message that was ended.
enum MentoraSnackbarState {
  hidden,
  showing,
  visible,
  updating,
  expiring,
  dismissed,
}

/// What the application announces about a message that reports an
/// ongoing state.
enum MentoraSnackbarPhase { idle, working }

/// A message never encloses and never dims.
///
/// Its elevation MEANING is the signalement: it waits at its own
/// level — no veil, no blocking, no layer taken from anyone. It never
/// competes with a dialog, and it never replaces a notification.
const ElevationMeaning snackbarElevationMeaning = ElevationMeaning.signalement;

/// How long a variant stays. A message that reports an ongoing state
/// never expires on its own: it leaves when the state ends, and the
/// application says when. Everything else disappears alone.
Duration? dwellOf(MentoraSnackbarVariant variant) {
  switch (variant) {
    case MentoraSnackbarVariant.sync:
    case MentoraSnackbarVariant.processing:
    case MentoraSnackbarVariant.offline:
      return null;
    case MentoraSnackbarVariant.warning:
    case MentoraSnackbarVariant.error:
      return snackbarExtendedDwell;
    case MentoraSnackbarVariant.information:
    case MentoraSnackbarVariant.success:
    case MentoraSnackbarVariant.custom:
      return snackbarStandardDwell;
  }
}

/// Whether a variant reports something still happening.
bool reportsOngoingState(MentoraSnackbarVariant variant) =>
    dwellOf(variant) == null;

/// Drives the work a message reports. One controller serves exactly
/// one message.
final class MentoraSnackbarController extends ChangeNotifier {
  MentoraSnackbarPhase _phase = MentoraSnackbarPhase.idle;

  MentoraSnackbarPhase get phase => _phase;

  void beginWorking() => _update(MentoraSnackbarPhase.working);

  void reset() => _update(MentoraSnackbarPhase.idle);

  void _update(MentoraSnackbarPhase next) {
    if (next == _phase) return;
    _phase = next;
    notifyListeners();
  }
}
