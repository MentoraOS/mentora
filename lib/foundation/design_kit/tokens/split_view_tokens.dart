/// The v1 materialization of the Split View contract (Component
/// domain, chapter Structure — catalog §D7). Values live here and
/// nowhere else; upstream admission follows the registry protocol.
///
/// A shared workspace carries almost nothing of its own: the line that
/// says two regions exist, the room a person may take hold of to move
/// it, and the step of a move asked without a pointer. The room the
/// regions take is never decided here — the application hands it,
/// already decided.
library;

/// The line that says two regions exist.
///
/// It is a line, never a border and never a decoration: no radius, no
/// shadow, no gradient exists for a separation.
const double splitViewSeparatorThickness = 1;

/// The room a person may take hold of, around the line.
///
/// It is never painted. The opposable reachable target always prevails
/// over it: a separation one can move is an interactive surface.
const double splitViewSeparatorGrabExtent = 12;

/// The smallest room a region can be given and still be a region.
///
/// It is a floor, never a proportion: the application decides the
/// room, and this refuses only what would make a region a lie.
const double splitViewMinimumRegionExtent = 160;

/// One step of a move asked without a pointer — by keyboard, or by a
/// screen reader acting on the separation.
const double splitViewResizeStep = 16;
