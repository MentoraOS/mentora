/// The v1 materialization of the Page Scaffold contract (Component
/// domain, chapter Structure — catalog §D7). Values live here and
/// nowhere else; upstream admission follows the registry protocol.
///
/// A page adds nothing to the content it carries: it owns the zones,
/// never their inside. That is why so few values exist here — a
/// container that measured or padded the content would be deciding
/// for it.
library;

/// The line a zone draws where it meets the content.
const double pageScaffoldDividerThickness = 1;

/// The line under the acts a page keeps at hand.
const double pageScaffoldFooterDividerThickness = 1;

/// A live page is fully present — nothing is taken from it.
const double pageScaffoldFullOpacity = 1;
