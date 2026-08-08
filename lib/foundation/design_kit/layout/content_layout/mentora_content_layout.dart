import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_regioned_layout.dart';

/// The official Content Layout — the way content is disposed in
/// Mentora.
///
/// It is not a page, not a screen, not a dashboard, not a grid and not
/// a list. It is the official disposition of content that is ALREADY
/// BUILT: named regions, read in the order the application announced
/// them, each one a landmark of its own and its own focus group.
///
/// What it owns is nothing but its official kind: the order, the
/// announcement, the refusals and the disposition belong to the
/// regioned foundation, once, for every shape whose regions the
/// application names. It creates no padding, no spacing and no scroll
/// view, and it hands every region on strictly intact.
///
/// The parent announces. The layout expresses. Always.
final class MentoraContentLayout extends MentoraRegionedLayout {
  const MentoraContentLayout({
    super.key,
    required super.frame,
    required super.regions,
    required super.pageSemanticLabel,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.content;
}
