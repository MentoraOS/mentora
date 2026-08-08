import 'package:flutter/widgets.dart';

import 'mentora_layout_assembly.dart';
import 'mentora_layout_style.dart';
import 'mentora_page_like_layout.dart';

/// What a layout whose content is a COLLECTION IS.
///
/// A collection is a logical sequence of elements the application
/// announces: the collection itself has an identity and a name, and
/// each element is an identity and what it is — already built. Only
/// the collection is announced; every element keeps its own voice, its
/// own identity and its own semantics, and the layer never speaks in
/// their place.
///
/// A list is that. A catalog a person goes through is that. Every
/// shape a future family will need where a whole presents elements
/// without owning them is that too — the same machinery, down to the
/// last refusal.
///
/// Everything such a shape has in common is owned here:
///
/// * what the collection IS — an identity, stable forever, never a
///   rank,
/// * what a screen reader hears about the collection, and about it
///   alone,
/// * the elements, in the order they were announced — all of them,
///   every time: nothing here selects, rearranges or holds one back,
/// * the refusals: no identity, no name, nothing presented, an element
///   without an identity, and an identity twice,
/// * the surface: the single collection disposition of the layer.
///
/// A shape built on it declares TWO things: which official kind it is,
/// and the words it calls the collection by. Those words are aliases,
/// never second fields: there is one collection, and one place where
/// it is held.
abstract base class MentoraCollectedLayout extends MentoraPageLikeLayout {
  /// What this collection IS — stable forever, never a position.
  final String collectionId;

  /// What the screen reader hears about the collection itself, and
  /// about it alone.
  final String collectionSemanticLabel;

  /// The elements, in the order they are to be read.
  final List<MentoraIdentifiedContent> contents;

  const MentoraCollectedLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required this.collectionId,
    required this.collectionSemanticLabel,
    required this.contents,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });

  @override
  void verify() {
    if (collectionId.isEmpty) {
      throw StateError('A collection without an identity is not one.');
    }
    if (collectionSemanticLabel.isEmpty) {
      throw StateError(
        'A collection without a name is not a landmark: a person '
        'always knows which collection they are reading.',
      );
    }
    if (contents.isEmpty) {
      throw StateError(
        'A collection presents elements: without one it presents '
        'nothing, and nothing is not a collection.',
      );
    }
    final identities = <String>{};
    for (final content in contents) {
      if (content.id.isEmpty) {
        throw StateError('An element without an identity is not one.');
      }
      if (!identities.add(content.id)) {
        throw StateError('Two elements never share one identity.');
      }
    }
  }

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    return MentoraLayoutSurface.collection(
      semanticLabel: pageSemanticLabel,
      place: place,
      facets: facets,
      intention: intention,
      acts: acts,
      collectionId: collectionId,
      collectionSemanticLabel: collectionSemanticLabel,
      items: contents,
    );
  }
}
