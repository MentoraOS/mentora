/// The v1 materialization of the Layout contract (Component domain,
/// chapter Layout — catalog §D7). Values live here and nowhere else;
/// upstream admission follows the registry protocol.
///
/// A layout materializes almost nothing: it composes. The whole family
/// shares this one file, because a layout that carried values of its
/// own would be deciding something it was handed.
library;

/// How the panels of a dashboard breathe.
///
/// It is a share of the hierarchical breathing, never a distance: the
/// relation belongs to the Spacing Engine, and only the proportion
/// lives here.
const double layoutPanelBreathingFactor = 1;

/// The room a layout adds around what it was handed.
///
/// It is zero, and it is a Token so that the zero is opposable: a
/// layout that ever padded a surface would be styling what it composes.
const double layoutContentGap = 0;

/// The smallest room a cell can be given and still be a cell.
///
/// It is a floor, never a proportion: the application decides the room
/// each cell takes, and this refuses only what would make a cell a lie.
const double layoutMinimumCellExtent = 96;
