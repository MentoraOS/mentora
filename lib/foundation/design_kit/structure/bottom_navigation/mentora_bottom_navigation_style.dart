import 'package:flutter/widgets.dart' show IconData;

import '../../components/badge/mentora_badge.dart';

/// A destination of the principal level.
///
/// A destination is an IDENTITY. It is not a position, not an index,
/// not an address: it is a place of the product, and it keeps the same
/// identity for as long as the product exists.
final class MentoraBottomNavigationDestination {
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

  const MentoraBottomNavigationDestination({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.badge,
    this.enabled = true,
  });
}

/// The states of one destination of the principal level.
///
/// The structure never invents them: availability, then where the
/// person is, then the focus, then the pointer.
enum MentoraBottomNavigationState { idle, selected, hovered, focused, disabled }
