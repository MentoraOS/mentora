/// The v1 materialization of the Bottom Navigation contract
/// (Component domain, chapter Structure — catalog §D7). Values live
/// here and nowhere else; upstream admission follows the registry
/// protocol.
///
/// Ergonomic intent, unchanged since it was validated: a compact
/// height inside the 60–64 dp band, single-line names, and a discreet
/// active capsule — chrome that never competes with the content
/// (DPV-05).
library;

final class BottomNavigationTokenSet {
  /// The height of the whole structure, inside the official compact
  /// band. Each full-height destination stays a reachable target.
  final double height;

  final double iconSize;
  final double capsuleRadius;
  final double capsuleHorizontalPadding;
  final double capsuleVerticalPadding;
  final double iconLabelGap;
  final double dividerThickness;

  const BottomNavigationTokenSet({
    required this.height,
    required this.iconSize,
    required this.capsuleRadius,
    required this.capsuleHorizontalPadding,
    required this.capsuleVerticalPadding,
    required this.iconLabelGap,
    required this.dividerThickness,
  });
}

const BottomNavigationTokenSet bottomNavigationTokens =
    BottomNavigationTokenSet(
      height: 62,
      iconSize: 22,
      capsuleRadius: 16,
      capsuleHorizontalPadding: 14,
      capsuleVerticalPadding: 4,
      iconLabelGap: 3,
      dividerThickness: 1,
    );

/// How present the ground of the chosen destination is.
const double bottomNavigationIndicatorOpacity = 0.12;

/// What a principal level of navigation admits.
///
/// Below the minimum there is no choice to express; above the maximum
/// the structure stops being a principal level and becomes a menu.
/// These are the extents of the contract, not a business rule.
const int bottomNavigationMinimumDestinations = 2;
const int bottomNavigationMaximumDestinations = 5;

/// A live structure is fully present — nothing is taken from it.
const double bottomNavigationFullOpacity = 1;

/// A structure that is no longer live is veiled.
const double bottomNavigationDisabledVeilOpacity = 0.38;
