import 'package:flutter/widgets.dart';

import '../../components/button/mentora_button.dart';
import '../../structure/app_bar/mentora_app_bar.dart';
import '../../structure/search_bar/mentora_search_bar.dart';
import '../../structure/tabs/mentora_tabs.dart';
import '../foundation/mentora_layout.dart';
import '../foundation/mentora_layout_assembly.dart';
import '../foundation/mentora_layout_context.dart';
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
final class MentoraWorkspaceLayout extends MentoraLayout {
  @override
  final MentoraLayoutContext frame;

  /// Where the person is - the App Bar remains its owner.
  final MentoraAppBar? place;

  /// The facets of the page - the Tabs remain their owner.
  final MentoraTabs? facets;

  /// The intention of finding - the Search Bar remains its owner.
  final MentoraSearchBar? intention;

  /// What the page carries. It belongs entirely to the application.
  final Widget content;

  /// The acts the page keeps at hand - the Button remains their owner.
  final List<MentoraButton> acts;

  /// What the screen reader hears about the page itself.
  final String pageSemanticLabel;

  const MentoraWorkspaceLayout({
    super.key,
    required this.frame,
    required this.content,
    required this.pageSemanticLabel,
    this.place,
    this.facets,
    this.intention,
    this.acts = const [],
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
