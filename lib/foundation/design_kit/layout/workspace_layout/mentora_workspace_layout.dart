import 'package:flutter/widgets.dart';

import '../foundation/mentora_layout_assembly.dart';
import '../foundation/mentora_page_like_layout.dart';
import '../foundation/mentora_layout_kind.dart';

/// The official Workspace Layout - one page, in the working context of
/// the product.
///
/// It is the shape of most screens: a place, the facets of that place,
/// the intention of finding inside it, what the person came to read,
/// and the acts kept at hand.
///
/// It is a specialization and nothing else: it declares its kind, the
/// context it was handed and the surface it asks for. The foundation
/// builds everything.
final class MentoraWorkspaceLayout extends MentoraPageLikeLayout {
  /// What the page carries. It belongs entirely to the application.
  final Widget content;

  const MentoraWorkspaceLayout({
    super.key,
    required super.frame,
    required this.content,
    required super.pageSemanticLabel,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.workspace;

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    return MentoraLayoutSurface.page(
      semanticLabel: pageSemanticLabel,
      place: place,
      facets: facets,
      intention: intention,
      acts: acts,
      content: content,
    );
  }
}
