import 'package:flutter/widgets.dart';

import 'mentora_layout_assembly.dart';
import 'mentora_layout_style.dart';
import 'mentora_page_like_layout.dart';

/// What a layout holding SEVERAL contents of one context, of which
/// exactly ONE is revealed, IS.
///
/// Several shapes of the product are that: the facets of a context, the
/// steps of a work, and every shape a future family will need where one
/// thing at a time is shown among several already decided.
///
/// Everything such a shape has in common is owned here:
///
/// * what the whole IS — an identity, stable forever, never a rank,
/// * what a screen reader hears about the whole, and about it alone,
/// * the contents, each an identity and what it is,
/// * which one is revealed — ANNOUNCED, never chosen here,
/// * the refusals: no identity, no name, nothing held, nothing
///   announced, an identity twice, and an announcement of something the
///   whole does not hold.
///
/// A shape built on it declares TWO things: which official kind it is,
/// and what it refuses as itself. It declares no identity, no order, no
/// surface and no build.
///
/// What is not revealed is NOT BUILT. It exists neither in the tree,
/// nor for the focus, nor for a screen reader: the assembly of the
/// layer is what reveals, and it reveals one thing only.
abstract base class MentoraRevealedLayout extends MentoraPageLikeLayout {
  /// What the whole IS — stable forever, never a position.
  final String contextId;

  /// What the screen reader hears about the whole itself, and about it
  /// alone.
  final String contextSemanticLabel;

  /// What the whole holds, already built.
  final List<MentoraIdentifiedContent> contents;

  /// Which content is revealed right now. The application announces it;
  /// the shape never chooses it, and never moves to another.
  final String revealedContentId;

  const MentoraRevealedLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required this.contextId,
    required this.contextSemanticLabel,
    required this.contents,
    required this.revealedContentId,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });

  /// What this shape refuses AS ITSELF.
  ///
  /// What every revealing shape refuses is refused above, once, and
  /// cannot be skipped: a specialization never overrides [verify], and
  /// a scan proves it.
  void verifyRevealed() {}

  @override
  void verify() {
    if (contextId.isEmpty) {
      throw StateError('A context without an identity is not one.');
    }
    if (contextSemanticLabel.isEmpty) {
      throw StateError(
        'A context without a name is not a landmark: a person always '
        'knows which context they are in.',
      );
    }
    if (contents.isEmpty) {
      throw StateError(
        'A context holds contents: without one it holds nothing, and '
        'nothing is not a context.',
      );
    }
    if (revealedContentId.isEmpty) {
      throw StateError(
        'A context is told what it reveals: an empty identity reveals '
        'nothing.',
      );
    }
    final identities = <String>{};
    for (final content in contents) {
      if (content.id.isEmpty) {
        throw StateError('A content without an identity is not one.');
      }
      if (!identities.add(content.id)) {
        throw StateError('Two contents never share one identity.');
      }
    }
    if (!identities.contains(revealedContentId)) {
      throw StateError(
        'The content announced as revealed is not one this context '
        'holds: a context never guesses what to show.',
      );
    }
    verifyRevealed();
  }

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    return MentoraLayoutSurface.revealed(
      semanticLabel: pageSemanticLabel,
      place: place,
      facets: facets,
      intention: intention,
      acts: acts,
      contextId: contextId,
      contextSemanticLabel: contextSemanticLabel,
      contents: contents,
      revealedContentId: revealedContentId,
    );
  }
}
