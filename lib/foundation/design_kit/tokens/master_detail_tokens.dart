/// The v1 materialization of the Master Detail contract (Component
/// domain, chapter Structure — catalog §D7). Values live here and
/// nowhere else; upstream admission follows the registry protocol.
///
/// A relation between two contexts carries almost nothing of its own:
/// the line that separates them, the veil over the one that waits, and
/// how present each of them is. The room they take is never decided
/// here — the application hands it, already decided.
library;

/// The line between the two spaces, when they stand side by side.
const double masterDetailDividerThickness = 1;

/// The veil over the space that waits, behind a presenting space that
/// passes in front of it.
const double masterDetailScrimOpacity = 0.48;

/// The smallest room a space can be given and still be a space.
///
/// It is a floor, never a proportion: the application decides the
/// room, and this refuses only what would make the relation a lie.
const double masterDetailMinimumPaneExtent = 200;
