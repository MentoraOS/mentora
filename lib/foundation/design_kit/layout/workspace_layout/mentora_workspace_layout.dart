import 'package:flutter/widgets.dart';

import '../../components/button/mentora_button.dart';
import '../../structure/app_bar/mentora_app_bar.dart';
import '../../structure/page_scaffold/mentora_page_scaffold.dart';
import '../../structure/search_bar/mentora_search_bar.dart';
import '../../structure/tabs/mentora_tabs.dart';
import '../../structure/workspace/mentora_workspace_style.dart';
import '../mentora_layout.dart';
import '../mentora_layout_style.dart';

/// The official Workspace Layout — one page, in the working context of
/// the product.
///
/// It is the shape of most screens: a place, the facets of that place,
/// the intention of finding inside it, what the person came to read,
/// and the acts kept at hand. The layout builds the official page so
/// that no product ever assembles one by hand.
///
/// It composes, and nothing else: no business, no data, no navigation
/// decision, no measure, no style of its own.
final class MentoraWorkspaceLayout extends StatelessWidget {
  /// What every layout of the family is handed.
  final MentoraLayoutContext frame;

  /// Where the person is — the App Bar remains its owner.
  final MentoraAppBar? place;

  /// The facets of the page — the Tabs remain their owner.
  final MentoraTabs? facets;

  /// The intention of finding — the Search Bar remains its owner.
  final MentoraSearchBar? intention;

  /// What the page carries. It belongs entirely to the application:
  /// the layout wraps it in nothing and changes nothing about it.
  final Widget content;

  /// The acts the page keeps at hand — the Button remains their owner.
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
  Widget build(BuildContext context) {
    if (pageSemanticLabel.isEmpty) {
      throw StateError(
        'A page announces the context it gathers: without a name it '
        'gathers nothing.',
      );
    }

    return MentoraLayoutAssembly(
      kind: MentoraLayoutKind.workspace,
      frame: frame,
      surface: MentoraWorkspaceSurface.page(
        MentoraPageScaffold(
          semanticLabel: pageSemanticLabel,
          place: place,
          facets: facets,
          intention: intention,
          acts: acts,
          content: content,
        ),
      ),
    );
  }
}
