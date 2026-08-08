import 'package:flutter/widgets.dart';

import 'mentora_layout_assembly.dart';
import 'mentora_layout_style.dart';
import 'mentora_page_like_layout.dart';

/// What a layout whose content is NAMED REGIONS, announced by the
/// application, IS.
///
/// Some shapes speak a closed vocabulary: the Design System already
/// knows their parts, and the zoned foundation is their way. These
/// shapes are the opposite: the APPLICATION names the regions, gives
/// each one an identity that never changes, and announces them in the
/// order it wants them read. Content disposed on a page is that, and a
/// space where a system is observed is that too — the same machinery,
/// down to the last refusal.
///
/// Everything such a shape has in common is owned here:
///
/// * the regions — an identity, a name, and what each one carries,
/// * the refusals: no region at all, a region without an identity, a
///   region without a name, and two regions sharing one identity,
/// * the surface: the single region disposition of the layer.
///
/// A shape built on it declares TWO things: which official kind it is,
/// and the word it calls its regions by. That word is an alias, never a
/// second field: there is one list, and one place where it is held.
abstract base class MentoraRegionedLayout extends MentoraPageLikeLayout {
  /// The regions, in the order they are to be read.
  final List<MentoraContentRegion> regions;

  const MentoraRegionedLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required this.regions,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });

  @override
  void verify() {
    if (regions.isEmpty) {
      throw StateError(
        'A regioned layout expresses what it was announced: without a '
        'region it expresses nothing, and nothing is not a page.',
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
