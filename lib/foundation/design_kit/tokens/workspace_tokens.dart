/// The v1 materialization of the Workspace contract (Component
/// domain, chapter Structure — catalog §D7). Values live here and
/// nowhere else; upstream admission follows the registry protocol.
///
/// A working context materializes almost nothing: it assembles. What
/// it does materialize is an ABSENCE — the room it adds between the
/// things it assembles — and an absence is declared here, as a value,
/// so that it is verified rather than assumed.
library;

/// The room a workspace adds between the zones it assembles.
///
/// It is zero, and it is a Token so that the zero is opposable: a
/// workspace that ever separated its zones by itself would be
/// deciding a disposition it was given.
const double workspaceZoneGap = 0;
