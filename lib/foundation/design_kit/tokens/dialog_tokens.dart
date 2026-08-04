/// The v1 materialization of the Dialog contract (Component domain,
/// chapter Overlay — catalog §D7). Values live here and nowhere else;
/// upstream admission follows the registry protocol.
library;

/// The widest a dialog is ever allowed to be: a conversation stays
/// readable, it never spreads across a desk.
const double dialogMaximumWidth = 420;

const double dialogCornerRadius = 20;
const double dialogBorderWidth = 1;

/// The veil that dims the scene behind an aparté (OpacityRole.scrim).
const double dialogScrimOpacity = 0.48;

/// The size of the variant's signature icon.
const double dialogIconSize = 28;

/// The stroke of the progress expression.
const double dialogProgressStroke = 3;

/// How far the layer travels while it arrives — a short rise, never
/// an entrance.
const double dialogEntryOffset = 12;
