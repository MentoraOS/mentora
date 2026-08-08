import 'package:flutter/widgets.dart';

import 'mentora_layout_assembly.dart';
import 'mentora_layout_style.dart';
import 'mentora_page_like_layout.dart';

/// What a layout whose parts are a CLOSED VOCABULARY IS.
///
/// Some shapes let the application name the regions it announces; those
/// are the open ones, and the Content Layout is their way. Other shapes
/// are the opposite: the Design System already knows which parts exist,
/// what they are called, and in which order they are read. A product
/// never invents one of those parts, never names one, and never places
/// one — it only says whether it has something to put there.
///
/// This foundation owns everything such a shape has in common:
///
/// * the parts of the page that belong to the official structures,
/// * the mapping from the vocabulary to the official regions,
/// * the order, which is the vocabulary itself and nothing else,
/// * the identity of a region, which IS the official region,
/// * the refusal of a region without a name.
///
/// A shape built on it therefore declares FOUR things: which official
/// kind it is, which vocabulary it speaks, what was given for each of
/// its regions, and what it refuses as itself. It declares no order, no
/// identity, no surface and no build — so two zoned shapes can never
/// drift apart, because there is nothing left for them to drift on.
abstract base class MentoraZonedLayout<TRegion extends Enum>
    extends MentoraPageLikeLayout {
  const MentoraZonedLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });

  /// The closed vocabulary of this shape, in the official order.
  ///
  /// It is the enumeration itself: the order a person reads the shape
  /// in is the order the vocabulary was declared in, so it cannot drift
  /// and no caller can reorder it.
  List<TRegion> get vocabulary;

  /// What was given for each region of the vocabulary.
  ///
  /// A region that was given nothing does not exist: it is absent from
  /// the tree, absent from the reading order and absent from what a
  /// screen reader announces.
  Map<TRegion, MentoraLayoutZone?> get zones;

  /// What this shape refuses AS ITSELF.
  ///
  /// What every zoned shape refuses is refused above, once, and cannot
  /// be skipped: a specialization never overrides [verify], and a scan
  /// proves it.
  void verifyZones() {}

  @override
  void verify() {
    final given = zones;
    for (final region in vocabulary) {
      final zone = given[region];
      if (zone == null) continue;
      if (zone.semanticLabel.isEmpty) {
        throw StateError(
          'A region without a name is not a landmark: a person always '
          'knows which part of the page they are in.',
        );
      }
    }
    verifyZones();
  }

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    final given = zones;

    return MentoraLayoutSurface.regions(
      semanticLabel: pageSemanticLabel,
      place: place,
      facets: facets,
      intention: intention,
      acts: acts,
      regions: [
        for (final region in vocabulary)
          if (given[region] case final zone?)
            MentoraContentRegion(
              // The identity of an official region IS the official
              // region it is: a product never names one.
              id: region.name,
              semanticLabel: zone.semanticLabel,
              content: zone.content,
            ),
      ],
    );
  }
}
