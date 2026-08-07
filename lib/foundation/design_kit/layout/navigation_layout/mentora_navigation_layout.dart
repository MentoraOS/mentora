import 'package:flutter/widgets.dart';

import '../foundation/mentora_layout.dart';
import '../foundation/mentora_layout_assembly.dart';
import '../foundation/mentora_layout_context.dart';
import '../foundation/mentora_layout_kind.dart';

/// The official Navigation Layout - the context whose whole point is
/// the way through the product.
///
/// It is the shape of the root of an application: the person moves
/// between the principal places, and each place shows what it holds.
/// The page carries the content alone - no place, no facets, no
/// intention - because everything that identifies where the person is
/// already belongs to the way through the product.
///
/// One thing it refuses, and it is what makes it this layout: a
/// navigation layout without a way through the product is not one.
final class MentoraNavigationLayout extends MentoraLayout {
  @override
  final MentoraLayoutContext frame;

  /// What the place carries. It belongs entirely to the application.
  final Widget content;

  /// What the screen reader hears about the place itself.
  final String pageSemanticLabel;

  const MentoraNavigationLayout({
    super.key,
    required this.frame,
    required this.content,
    required this.pageSemanticLabel,
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.navigation;

  @override
  void verify() {
    if (!frame.carriesNavigation) {
      throw StateError(
        'A navigation layout is the way through the product: without a '
        'way through it, it is a workspace layout.',
      );
    }
  }

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    return MentoraLayoutSurface.page(
      semanticLabel: pageSemanticLabel,
      content: content,
    );
  }
}
