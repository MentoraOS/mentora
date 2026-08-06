import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show IconData;

import '../../components/badge/mentora_badge.dart';

/// How loudly a set of facets speaks. A primary set organizes the
/// facets of a context; a secondary one organizes the facets of a
/// facet, and stays quieter.
enum MentoraTabsEmphasis { primary, secondary }

/// How the chosen facet is drawn.
enum MentoraTabsShape { underline, segmented, contained }

/// What the set does when its facets no longer fit.
///
/// The application declares it — it knows the surface. The set never
/// measures anything.
enum MentoraTabsOverflow {
  /// The facets keep their room and the set scrolls.
  scroll,

  /// The facets share the room they are given.
  fit,
}

/// The six official states of one facet.
enum MentoraTabsState { idle, selected, hovered, focused, disabled, loading }

/// A facet of one context — an IDENTITY.
///
/// It is not a position, not an address and not a page: the set knows
/// which facets exist, never what they contain. Changing facet never
/// means leaving the context.
final class MentoraTab {
  /// What this facet IS — stable forever, never a position.
  final String id;

  /// What it is called. The application owns every string
  /// (Localization Engine); the Kit composes none.
  final String label;

  /// What situates the facet at a glance.
  final IconData? icon;

  /// What is happening in it — the Badge remains its owner.
  final MentoraBadge? badge;

  /// Whether the facet can be shown right now.
  final bool enabled;

  /// Whether the facet is still being prepared. A facet that is not
  /// ready is never chosen.
  final bool loading;

  const MentoraTab({
    required this.id,
    required this.label,
    this.icon,
    this.badge,
    this.enabled = true,
    this.loading = false,
  });

  bool get reachable => enabled && !loading;
}

/// Carries which facet of the context is shown.
///
/// The set never decides what to show: it reports an intention, and
/// the application announces the facet it revealed.
final class MentoraTabsController extends ChangeNotifier {
  String _selectedId;

  MentoraTabsController(this._selectedId);

  /// The identity of the facet on screen — never a position.
  String get selectedId => _selectedId;

  void announceSelection(String id) {
    if (id == _selectedId) return;
    _selectedId = id;
    notifyListeners();
  }
}
