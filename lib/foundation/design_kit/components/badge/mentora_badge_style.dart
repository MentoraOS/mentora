import 'package:flutter/foundation.dart';

/// The eleven official state meanings — the only badge vocabulary the
/// business screens will ever speak. No screen ever touches Chip,
/// InputChip, ChoiceChip, FilterChip, ActionChip or RawChip.
enum MentoraBadgeVariant {
  neutral,
  information,
  success,
  warning,
  critical,
  verified,
  premium,
  ai,
  offline,
  sync,
  custom,
}

/// The six official forms. A form says how much room the state needs
/// to be understood — never how decorative it should look.
enum MentoraBadgeShape { label, pill, dot, icon, compact, extended }

/// The three official sizes.
enum MentoraBadgeSize { small, medium, large }

/// The six official states of the state language itself.
enum MentoraBadgeState {
  idle,
  highlighted,
  disabled,
  processing,
  selected,
  archived,
}

/// A form that shows no words says nothing to a screen reader on its
/// own — its meaning must be spoken, never left to the colour.
bool showsWords(MentoraBadgeShape shape) {
  switch (shape) {
    case MentoraBadgeShape.dot:
    case MentoraBadgeShape.icon:
      return false;
    case MentoraBadgeShape.label:
    case MentoraBadgeShape.pill:
    case MentoraBadgeShape.compact:
    case MentoraBadgeShape.extended:
      return true;
  }
}

/// Whether a form carries a pictogram beside its words.
bool showsIcon(MentoraBadgeShape shape) {
  switch (shape) {
    case MentoraBadgeShape.icon:
    case MentoraBadgeShape.compact:
    case MentoraBadgeShape.extended:
      return true;
    case MentoraBadgeShape.label:
    case MentoraBadgeShape.pill:
    case MentoraBadgeShape.dot:
      return false;
  }
}

/// Carries the state of one badge over time. A badge is never
/// interactive: its state always comes from outside — the application
/// announces it, the badge affirms it.
final class MentoraBadgeController extends ChangeNotifier {
  MentoraBadgeState _state;

  MentoraBadgeController([MentoraBadgeState initial = MentoraBadgeState.idle])
    : _state = initial;

  MentoraBadgeState get state => _state;

  void announce(MentoraBadgeState state) {
    if (state == _state) return;
    _state = state;
    notifyListeners();
  }
}
