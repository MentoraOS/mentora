import 'package:flutter/widgets.dart' show IconData;

import '../components/badge/mentora_badge.dart';

/// How a structure presents THE WAY TO a place.
///
/// A destination is not the place: the place is defined once, by the
/// official route, and a destination only REFERS to it — by the one
/// identity the product will use forever. What a destination owns is
/// everything a structure needs to offer the way there: the words a
/// person reads, the signs they recognise, what is happening there,
/// and whether the way is open right now.
///
/// There is ONE destination type for the whole Kit. The principal
/// level, the map of the person's space and the rail all present ways
/// to places — the same concept, so the same type, and a scan proves
/// no structure can ever declare a destination of its own again.
///
/// It is not a position, not an index and not an address: structures
/// report the identity that was asked for, and the application alone
/// decides what happens then.
final class MentoraDestination {
  /// The identity of the place this destination leads to — stable
  /// forever, never a position.
  final String id;

  /// What it is called. The application owns every string
  /// (Localization Engine); the Kit composes none.
  final String label;

  final IconData icon;
  final IconData selectedIcon;

  /// What is happening there — the Badge remains its owner.
  final MentoraBadge? badge;

  /// Whether the way is open right now.
  final bool enabled;

  const MentoraDestination({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.badge,
    this.enabled = true,
  });
}
