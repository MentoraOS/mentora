import 'package:flutter/widgets.dart';

import '../foundation/mentora_layout_assembly.dart';
import '../foundation/mentora_page_like_layout.dart';
import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';

/// The official Content Layout — the way content is disposed in
/// Mentora.
///
/// It is not a page, not a screen, not a dashboard, not a grid and not
/// a list. It is the official disposition of content that is ALREADY
/// BUILT: named regions, read in the order the application announced
/// them, each one a landmark of its own and its own focus group.
///
/// What it owns is the ORDER and the ANNOUNCEMENT. What it never owns
/// is the room: it creates no padding, no spacing, no scroll view. It
/// adds nothing at all between what it was handed — the absence is a
/// Token, so that it is opposable rather than assumed — and it hands
/// every region on strictly intact.
///
/// The parent announces. The layout expresses. Always.
final class MentoraContentLayout extends MentoraPageLikeLayout {
  /// The regions of content, in the order they are to be read.
  final List<MentoraContentRegion> regions;

  const MentoraContentLayout({
    super.key,
    required super.frame,
    required this.regions,
    required super.pageSemanticLabel,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.content;

  @override
  void verify() {
    if (regions.isEmpty) {
      throw StateError(
        'A content layout disposes content: without a region it '
        'disposes nothing, and nothing is not a disposition.',
      );
    }
    final identities = <String>{};
    for (final region in regions) {
      if (region.id.isEmpty) {
        throw StateError('A region without an identity is not a region.');
      }
      if (region.semanticLabel.isEmpty) {
        throw StateError(
          'A region without a name is not a landmark: a person always '
          'knows which region they are reading.',
        );
      }
      if (!identities.add(region.id)) {
        throw StateError('Two regions never share one identity.');
      }
    }
  }

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    return MentoraLayoutSurface.regions(
      semanticLabel: pageSemanticLabel,
      place: place,
      facets: facets,
      intention: intention,
      acts: acts,
      regions: regions,
    );
  }
}
