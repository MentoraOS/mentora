import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show IconData;

import '../../components/badge/mentora_badge.dart';
import '../../tokens/drawer_tokens.dart';

/// How the orientation map is presented.
///
/// The application announces it — it knows the surface and the moment.
/// The map never chooses how it appears.
enum MentoraDrawerPresentation { permanent, modal, dismissible }

/// Whether the map is shown.
///
/// The map never opens itself and never closes itself: it is told.
enum MentoraDrawerVisibility { opened, closed }

/// The states of one destination of the map.
enum MentoraDrawerState { idle, selected, hovered, focused, disabled }

/// A destination is an IDENTITY.
///
/// It is not a position and not an address: it is a place of the
/// person's space, and it keeps the same identity for as long as the
/// product exists.
final class MentoraDrawerDestination {
  /// What this place IS — stable forever, never a position.
  final String id;

  /// What it is called. The application owns every string
  /// (Localization Engine); the Kit composes none.
  final String label;

  final IconData icon;
  final IconData selectedIcon;

  /// What is happening there — the Badge remains its owner.
  final MentoraBadge? badge;

  /// Whether the place can be reached right now.
  final bool enabled;

  const MentoraDrawerDestination({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.badge,
    this.enabled = true,
  });
}

/// A named group of places. A map without sections is a map with one.
final class MentoraDrawerSection {
  /// What this group of places is called, when it deserves a name.
  final String? title;

  final List<MentoraDrawerDestination> destinations;

  const MentoraDrawerSection({required this.destinations, this.title});
}

/// The presentation a variant materializes.
DrawerPresentationSpec specOf(MentoraDrawerPresentation presentation) {
  switch (presentation) {
    case MentoraDrawerPresentation.permanent:
      return permanentDrawerSpec;
    case MentoraDrawerPresentation.modal:
      return modalDrawerSpec;
    case MentoraDrawerPresentation.dismissible:
      return dismissibleDrawerSpec;
  }
}

/// Whether a presentation may be put away by the person themselves.
/// A permanent map belongs to the chrome: it is never dismissed.
bool acceptsDismissal(MentoraDrawerPresentation presentation) =>
    presentation != MentoraDrawerPresentation.permanent;

/// Carries what the application knows: where the person is, and
/// whether the map is shown.
///
/// The map never writes here: it reports intentions, and the
/// application announces what it decided.
final class MentoraNavigationDrawerController extends ChangeNotifier {
  String? _selectedId;
  MentoraDrawerVisibility _visibility;

  MentoraNavigationDrawerController({
    String? selectedId,
    MentoraDrawerVisibility visibility = MentoraDrawerVisibility.closed,
  }) : _selectedId = selectedId,
       _visibility = visibility;

  /// The identity of the place the person is in — never a position.
  String? get selectedId => _selectedId;

  MentoraDrawerVisibility get visibility => _visibility;

  bool get isOpened => _visibility == MentoraDrawerVisibility.opened;

  void announceSelection(String? id) {
    if (id == _selectedId) return;
    _selectedId = id;
    notifyListeners();
  }

  void announceVisibility(MentoraDrawerVisibility visibility) {
    if (visibility == _visibility) return;
    _visibility = visibility;
    notifyListeners();
  }
}
