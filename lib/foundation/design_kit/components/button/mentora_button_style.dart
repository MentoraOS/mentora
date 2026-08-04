import 'package:flutter/foundation.dart';

/// The six official button variants — the only button vocabulary the
/// business screens will ever speak. No screen ever touches
/// ElevatedButton, FilledButton, OutlinedButton or TextButton.
enum MentoraButtonVariant { contained, outlined, text, tonal, danger, success }

/// The three official sizes — every dimension comes from the tokens
/// layer; the opposable reachable target always prevails.
enum MentoraButtonSize { small, medium, large }

/// Where an optional icon sits relative to the label.
enum MentoraButtonIconPosition { leading, trailing }

/// The eight official visual states. Exactly one is effective at any
/// moment; the resolution order is owned by the component.
enum MentoraButtonState {
  idle,
  pressed,
  focused,
  hovered,
  disabled,
  loading,
  success,
  error,
}

/// The lifecycle phases an application drives from outside the widget
/// (interaction states stay internal — they belong to the finger and
/// the focus, never to the business).
enum MentoraButtonPhase { idle, loading, success, error }

/// Drives the asynchronous phases of one button: the application layer
/// announces what is happening; the button expresses it. One
/// controller serves exactly one button (single responsibility).
final class MentoraButtonController extends ChangeNotifier {
  MentoraButtonPhase _phase = MentoraButtonPhase.idle;

  MentoraButtonPhase get phase => _phase;

  void beginLoading() => _update(MentoraButtonPhase.loading);

  void showSuccess() => _update(MentoraButtonPhase.success);

  void showError() => _update(MentoraButtonPhase.error);

  void reset() => _update(MentoraButtonPhase.idle);

  void _update(MentoraButtonPhase next) {
    if (next == _phase) return;
    _phase = next;
    notifyListeners();
  }
}
