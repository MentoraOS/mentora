import 'package:flutter/widgets.dart';

import '../../structure/page_scaffold/mentora_page_scaffold.dart';
import '../../structure/workspace/mentora_workspace_style.dart';
import '../mentora_layout.dart';
import '../mentora_layout_style.dart';

/// The official Navigation Layout — the context whose whole point is
/// the way through the product.
///
/// It is the shape of the root of an application: the person moves
/// between the principal places, and each place shows what it holds.
/// The page carries the content alone — no place, no facets, no
/// intention — because everything that identifies where the person is
/// already belongs to the way through the product.
///
/// One thing it refuses, and it is what makes it this layout: a
/// navigation layout without a way through the product is not one.
final class MentoraNavigationLayout extends StatelessWidget {
  /// What every layout of the family is handed.
  final MentoraLayoutContext frame;

  /// What the place carries. It belongs entirely to the application:
  /// the layout wraps it in nothing and changes nothing about it.
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
  Widget build(BuildContext context) {
    if (pageSemanticLabel.isEmpty) {
      throw StateError(
        'A place announces itself: without a name a person never knows '
        'where they are.',
      );
    }
    if (!frame.carriesNavigation) {
      throw StateError(
        'A navigation layout is the way through the product: without a '
        'way through it, it is a workspace layout.',
      );
    }

    return MentoraLayoutAssembly(
      kind: MentoraLayoutKind.navigation,
      frame: frame,
      surface: MentoraWorkspaceSurface.page(
        MentoraPageScaffold(semanticLabel: pageSemanticLabel, content: content),
      ),
    );
  }
}
