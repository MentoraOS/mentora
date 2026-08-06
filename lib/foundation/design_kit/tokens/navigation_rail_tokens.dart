/// The v1 materialization of the Navigation Rail contract (Component
/// domain, chapter Structure — catalog §D7). Values live here and
/// nowhere else; upstream admission follows the registry protocol.
library;

/// How much of itself the structure shows. The choice belongs to the
/// application: the structure never measures the surface it lives on.
final class NavigationRailDisplaySpec {
  final double width;

  /// Whether the words stand beside the marks at this display.
  final bool showsWords;

  const NavigationRailDisplaySpec({
    required this.width,
    required this.showsWords,
  });
}

const NavigationRailDisplaySpec compactRailSpec = NavigationRailDisplaySpec(
  width: 80,
  showsWords: false,
);
const NavigationRailDisplaySpec expandedRailSpec = NavigationRailDisplaySpec(
  width: 256,
  showsWords: true,
);

/// The extent of one destination — the opposable reachable target
/// always prevails over it.
const double navigationRailDestinationExtent = 56;
const double navigationRailIconSize = 24;
const double navigationRailIndicatorRadius = 12;
const double navigationRailFloatingRadius = 20;
const double navigationRailBorderWidth = 1;
const double navigationRailDividerThickness = 1;

/// How present the ground of the chosen destination is.
const double navigationRailIndicatorOpacity = 0.12;

/// A live structure is fully present — nothing is taken from it.
const double navigationRailFullOpacity = 1;

/// A structure that is no longer live is veiled.
const double navigationRailDisabledVeilOpacity = 0.38;
