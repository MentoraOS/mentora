import 'package:flutter/foundation.dart';

/// The six official container variants — the only card vocabulary the
/// business screens will ever speak. No screen ever touches Material's
/// Card, nor decorates a Container to imitate one.
///
/// The selection is carried by the variant — one truth, never a
/// boolean competing with it: the application promotes the chosen card
/// to [MentoraCardVariant.selected].
enum MentoraCardVariant {
  surface,
  outlined,
  elevated,
  interactive,
  selected,
  protected,
}

/// The eight official visual states. Exactly one is effective at any
/// moment; the resolution order is owned by the component.
enum MentoraCardState {
  idle,
  pressed,
  focused,
  hovered,
  selected,
  disabled,
  loading,
  error,
}

/// The lifecycle phases an application drives from outside the widget.
///
/// A card contains — it never confirms an act: there is no success
/// phase here (that belongs to the button). Loading says the content
/// is not there yet; error says it could not be obtained.
enum MentoraCardPhase { idle, loading, error }

/// Drives the asynchronous phases of one card: the application layer
/// announces the state of the content; the card expresses it without
/// ever deciding what the content is. One controller serves exactly
/// one card (single responsibility).
final class MentoraCardController extends ChangeNotifier {
  MentoraCardPhase _phase = MentoraCardPhase.idle;

  MentoraCardPhase get phase => _phase;

  void beginLoading() => _update(MentoraCardPhase.loading);

  void showError() => _update(MentoraCardPhase.error);

  void reset() => _update(MentoraCardPhase.idle);

  void _update(MentoraCardPhase next) {
    if (next == _phase) return;
    _phase = next;
    notifyListeners();
  }
}
