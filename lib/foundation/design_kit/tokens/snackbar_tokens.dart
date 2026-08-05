/// The v1 materialization of the Snackbar contract (Component domain,
/// chapter Signal — catalog §D7). Values live here and nowhere else;
/// upstream admission follows the registry protocol.
library;

/// How long a message stays. This is READING time, not motion time:
/// the Motion preference never shortens it — a message no one had
/// time to read has not been delivered.
const Duration snackbarStandardDwell = Duration(seconds: 4);

/// What deserves a second reading stays longer.
const Duration snackbarExtendedDwell = Duration(seconds: 7);

/// A message stays readable on a wide screen: it accompanies a column
/// of content, it never spans a desk.
const double snackbarMaximumWidth = 560;

const double snackbarCornerRadius = 12;
const double snackbarBorderWidth = 1;

/// The distance kept from the edge of the scene — the message rests
/// above what the screen already carries.
const double snackbarIconSize = 20;
const double snackbarProgressStroke = 2;

/// How far the message travels while it arrives — a short rise, never
/// an entrance.
const double snackbarEntryOffset = 16;
