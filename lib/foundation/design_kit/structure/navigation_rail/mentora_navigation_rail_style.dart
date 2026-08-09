import 'package:flutter/foundation.dart';

import '../../tokens/navigation_rail_tokens.dart';

/// How much of itself the structure shows.
///
/// The choice belongs to the application — the Responsive Engine
/// decides what a surface deserves; the structure only expresses what
/// it was told.
enum MentoraNavigationRailDisplay { compact, expanded }

/// How the structure rests beside the content.
enum MentoraNavigationRailChrome { surface, floating, transparent }

/// The seven official states. Three describe the structure itself
/// (collapsed, expanded, disabled); five describe one destination
/// within it (idle, selected, hovered, focused, disabled).
enum MentoraNavigationRailState {
  idle,
  selected,
  hovered,
  focused,
  disabled,
  collapsed,
  expanded,
}

/// The act that changes how much the structure shows. A control
/// without a name is never rendered: the label is required, and the
/// application performs the change — the structure only reports it.
final class MentoraNavigationRailToggle {
  final String label;
  final VoidCallback onInvoke;

  const MentoraNavigationRailToggle({
    required this.label,
    required this.onInvoke,
  });
}

/// The display a variant materializes.
NavigationRailDisplaySpec specOf(MentoraNavigationRailDisplay display) {
  switch (display) {
    case MentoraNavigationRailDisplay.compact:
      return compactRailSpec;
    case MentoraNavigationRailDisplay.expanded:
      return expandedRailSpec;
  }
}

/// Carries what the application knows: which place the person is in,
/// and whether the structure is live.
///
/// The structure never decides where to go: it reports an intention,
/// and the application announces the place it landed in.
final class MentoraNavigationRailController extends ChangeNotifier {
  String? _selectedId;
  bool _enabled = true;

  MentoraNavigationRailController([this._selectedId]);

  /// The identity of the place the person is in — never a position.
  String? get selectedId => _selectedId;

  bool get enabled => _enabled;

  void announceSelection(String? id) {
    if (id == _selectedId) return;
    _selectedId = id;
    notifyListeners();
  }

  void announceAvailability({required bool enabled}) {
    if (enabled == _enabled) return;
    _enabled = enabled;
    notifyListeners();
  }
}
