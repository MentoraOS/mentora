import 'package:flutter/widgets.dart';

/// The v1 materialization of the root navigation chrome — a compact,
/// one-hand bar. Values live here and nowhere else; their upstream
/// admission (Component domain, chapter Navigation) follows the
/// registry protocol like the Responsive thresholds.
///
/// Ergonomic intent: compact height (60–64 dp band), single-line
/// labels, a discreet active capsule — calm chrome that never
/// competes with the content (DPV-05).
final class NavigationBarTokenSet {
  /// Bar height, inside the official compact band (60–64 dp). The
  /// full-height item remains a reachable target (≥ 48 dp — Interaction
  /// Space).
  final double height;
  final double iconSize;
  final double labelSize;
  final FontWeight labelWeight;
  final double capsuleRadius;
  final double capsuleHorizontalPadding;
  final double capsuleVerticalPadding;
  final double iconLabelGap;

  const NavigationBarTokenSet({
    required this.height,
    required this.iconSize,
    required this.labelSize,
    required this.labelWeight,
    required this.capsuleRadius,
    required this.capsuleHorizontalPadding,
    required this.capsuleVerticalPadding,
    required this.iconLabelGap,
  });
}

const NavigationBarTokenSet navigationBarTokens = NavigationBarTokenSet(
  height: 62,
  iconSize: 22,
  labelSize: 11,
  labelWeight: FontWeight.w500,
  capsuleRadius: 16,
  capsuleHorizontalPadding: 14,
  capsuleVerticalPadding: 4,
  iconLabelGap: 3,
);

/// The single-line 11 sp label style of the bar — built here so no
/// chrome widget ever carries a font size (the tokens layer is the
/// values home).
TextStyle navigationBarLabelStyle({required Color color}) {
  return TextStyle(
    fontSize: navigationBarTokens.labelSize,
    fontWeight: navigationBarTokens.labelWeight,
    color: color,
  );
}
