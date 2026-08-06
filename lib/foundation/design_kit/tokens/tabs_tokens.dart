/// The v1 materialization of the Tabs contract (Component domain,
/// chapter Structure — catalog §D7). Values live here and nowhere
/// else; upstream admission follows the registry protocol.
library;

/// The extent of one facet — the opposable reachable target always
/// prevails over it.
const double tabExtent = 48;

/// The narrowest a facet is ever presented: a name needs room to be
/// read before it is chosen.
const double tabMinimumWidth = 72;

const double tabIconSize = 18;

/// The line that says which facet is shown.
const double tabIndicatorThickness = 3;
const double tabIndicatorRadius = 3;

/// The enclosures the shapes materialize.
const double tabSegmentedRadius = 10;
const double tabContainedRadius = 12;
const double tabsBorderWidth = 1;

/// How present the ground of the chosen facet is.
const double tabSelectedGroundOpacity = 0.12;

/// A live set is fully present — nothing is taken from it.
const double tabsFullOpacity = 1;

/// A facet that cannot be shown right now is veiled.
const double tabsDisabledVeilOpacity = 0.38;

const double tabProgressStroke = 2;
const double tabProgressExtent = 16;
