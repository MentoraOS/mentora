import 'package:flutter/widgets.dart' show Widget;

import '../../tokens/split_view_tokens.dart';

/// Along which line the workspace is shared.
///
/// The application announces it — it alone knows the surface and the
/// moment. The workspace never chooses how it is shared, and it never
/// reads an orientation of its own.
enum MentoraSplitAxis { horizontal, vertical }

/// Whether a region is part of the workspace right now.
///
/// A region that is hidden does not exist: it is not built, it takes
/// no focus, it says nothing and it receives nothing.
enum MentoraSplitRegionVisibility { shown, hidden }

/// The states of one separation.
///
/// A separation that cannot be moved is fixed: it says that two
/// regions exist, and offers nothing else.
enum MentoraSplitSeparatorState { fixed, idle, hovered, dragged }

/// A region of the workspace.
///
/// A region is an IDENTITY. It is not a position and not an index: it
/// is a place of the workspace, and it keeps the same identity for as
/// long as the product exists.
final class MentoraSplitRegion {
  /// What this region IS — stable forever, never a position.
  final String id;

  /// What the screen reader hears about the region itself: a landmark
  /// name. The application owns every string; the Kit composes none.
  final String semanticLabel;

  /// What the region carries. It belongs entirely to the application:
  /// the workspace wraps it in nothing and changes nothing about it.
  final Widget content;

  /// Whether the region is part of the workspace right now.
  final MentoraSplitRegionVisibility visibility;

  /// What the screen reader hears about the separation that changes
  /// this region's room. It is required as soon as the workspace can
  /// be moved: a control without a name is never offered.
  final String? resizeSemanticLabel;

  const MentoraSplitRegion({
    required this.id,
    required this.semanticLabel,
    required this.content,
    this.visibility = MentoraSplitRegionVisibility.shown,
    this.resizeSemanticLabel,
  });

  bool get isShown => visibility == MentoraSplitRegionVisibility.shown;
}

/// The room the regions take, already decided by the application.
///
/// The workspace never measures the surface, never reads a breakpoint
/// and never computes a proportion: it is given extents by identity,
/// and it expresses them.
///
/// Exactly one region takes what is left of the room. It is named by
/// its identity — never by its rank — so a workspace can be shared in
/// any order without a single position ever existing.
final class MentoraSplitLayoutSpecification {
  final MentoraSplitAxis axis;

  /// The room of each region, by identity. The region that takes what
  /// is left never appears here.
  final Map<String, double> extents;

  /// The identity of the region that takes what is left.
  final String fillsRemainingRegionId;

  const MentoraSplitLayoutSpecification({
    required this.extents,
    required this.fillsRemainingRegionId,
    this.axis = MentoraSplitAxis.horizontal,
  });

  double? extentOf(String regionId) => extents[regionId];

  /// What the specification alone can verify — fail closed.
  ///
  /// It verifies a floor and a naming; it never chooses an extent.
  void verify() {
    if (fillsRemainingRegionId.isEmpty) {
      throw StateError(
        'A shared room needs a region that takes what is left, and a '
        'region is named by its identity.',
      );
    }
    if (extents.containsKey(fillsRemainingRegionId)) {
      throw StateError(
        'The region that takes what is left never carries an extent: '
        'what is left is not a room one announces.',
      );
    }
    for (final entry in extents.entries) {
      if (entry.key.isEmpty) {
        throw StateError('A room announced for no identity is not a room.');
      }
      if (!entry.value.isFinite || entry.value < splitViewMinimumRegionExtent) {
        throw StateError(
          'A region needs room to be a region: the extent announced '
          'for "${entry.key}" is below the opposable floor of '
          '$splitViewMinimumRegionExtent.',
        );
      }
    }
  }
}

/// What a person asked of a separation.
///
/// The workspace reports the identity of the region whose room would
/// change, and by how much — never a new size, and never a decision.
final class MentoraSplitResizeIntention {
  /// The identity of the region the person is making bigger or
  /// smaller — never a position, and never the separation itself.
  final String regionId;

  /// How much room was asked for, in the direction that makes the
  /// region bigger. The application decides what to do with it.
  final double delta;

  const MentoraSplitResizeIntention({
    required this.regionId,
    required this.delta,
  });
}
