/// The v1 materialization of the Bottom Sheet contract (Component
/// domain, chapter Overlay — catalog §D7). Values live here and
/// nowhere else; upstream admission follows the registry protocol.
library;

/// The two official detents, as fractions of the available height.
/// A sheet extends the screen — it never becomes a page.
const double bottomSheetCollapsedFraction = 0.45;
const double bottomSheetExpandedFraction = 0.92;

/// Past this fraction of travel, releasing lets the sheet go: the
/// gesture is read as "I am done", never as an accident.
const double bottomSheetDismissTravelFraction = 0.35;

/// A sheet stays readable on a wide screen: it accompanies a column
/// of content, it never spreads across a desk.
const double bottomSheetMaximumWidth = 640;

const double bottomSheetCornerRadius = 24;
const double bottomSheetBorderWidth = 1;

/// A veil lighter than a dialog's: the sheet accompanies the scene,
/// it does not interrupt it.
const double bottomSheetScrimOpacity = 0.32;

/// The grip that says "this can be moved".
const double bottomSheetHandleWidth = 36;
const double bottomSheetHandleHeight = 4;
const double bottomSheetHandleRadius = 2;

const double bottomSheetProgressStroke = 3;
