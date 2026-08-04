import 'package:flutter/foundation.dart';

import 'mentora_input_validator.dart';

/// The official field chromes — how a field presents itself.
///
/// Availability (read-only, disabled) is deliberately NOT a chrome:
/// see [MentoraInputAvailability]. Any chrome can be read-only or
/// disabled, and a form never loses its search or secure affordance
/// because a value became temporarily untouchable.
enum MentoraInputVariant { filled, outlined, underlined, search, secure }

/// Whether the value may be changed — orthogonal to the chrome, so
/// the two compose instead of competing.
enum MentoraInputAvailability { editable, readOnly, disabled }

/// The three official sizes — every dimension comes from the tokens
/// layer; the opposable reachable target always prevails.
enum MentoraInputSize { small, medium, large }

/// The eleven official visual states. Exactly one is effective at any
/// moment; the resolution order is owned by the component.
enum MentoraInputState {
  idle,
  focused,
  typing,
  filled,
  valid,
  invalid,
  loading,
  disabled,
  readOnly,
  success,
  error,
}

/// The asynchronous phases an application drives from outside the
/// widget — the outcome of a remote verification, never a local rule.
///
/// They are distinct from the validation states: `invalid` is what a
/// validator says about the value here and now; `error` is what the
/// application reports about the act it attempted.
enum MentoraInputPhase { idle, loading, success, error }

/// Drives the asynchronous phases and carries the published
/// validation verdict of one field. The application announces; the
/// field expresses. One controller serves exactly one field.
final class MentoraInputController extends ChangeNotifier {
  MentoraInputPhase _phase = MentoraInputPhase.idle;
  MentoraValidation _validation = MentoraValidation.pristine;

  MentoraInputPhase get phase => _phase;

  MentoraValidation get validation => _validation;

  void beginLoading() => _updatePhase(MentoraInputPhase.loading);

  void showSuccess() => _updatePhase(MentoraInputPhase.success);

  void showError() => _updatePhase(MentoraInputPhase.error);

  void reset() => _updatePhase(MentoraInputPhase.idle);

  /// The business publishes its verdict — the Kit never computes one.
  void publishValidation(MentoraValidation validation) {
    if (validation == _validation) return;
    _validation = validation;
    notifyListeners();
  }

  void _updatePhase(MentoraInputPhase next) {
    if (next == _phase) return;
    _phase = next;
    notifyListeners();
  }
}
