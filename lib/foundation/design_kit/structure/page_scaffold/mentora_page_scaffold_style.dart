import '../navigation_drawer/mentora_navigation_drawer_style.dart';

/// Where a zone stands relative to the content.
///
/// A page never chooses: it reads what the application already
/// declared on the structure it was given.
enum MentoraPageZonePlacement {
  /// The zone stands beside the content and takes its own room.
  beside,

  /// The zone passes in front of the content and takes none.
  over,
}

/// Where an orientation map stands, read from the presentation the
/// application announced on it.
///
/// This is expression, never decision: the map already knows how it
/// is presented, and the page only places it accordingly.
MentoraPageZonePlacement placementOf(MentoraDrawerPresentation presentation) {
  return standsBeside(presentation)
      ? MentoraPageZonePlacement.beside
      : MentoraPageZonePlacement.over;
}

/// The official zones of a page.
///
/// They exist so that a page is always assembled the same way, in
/// every context of the product: a place, a way through it, a
/// content, the acts kept at hand, and the layers that come and go.
enum MentoraPageZone { place, orientation, facets, intention, content, acts }
