import 'package:flutter/widgets.dart';

import '../../components/button/mentora_button.dart';
import '../../structure/app_bar/mentora_app_bar.dart';
import '../../structure/master_detail/mentora_master_detail.dart';
import '../../structure/page_scaffold/mentora_page_scaffold.dart';
import '../../structure/search_bar/mentora_search_bar.dart';
import '../../structure/split_view/mentora_split_view.dart';
import '../../structure/tabs/mentora_tabs.dart';
import '../../structure/workspace/mentora_workspace.dart';
import '../../structure/workspace/mentora_workspace_style.dart';
import 'mentora_layout_context.dart';
import 'mentora_layout_kind.dart';

/// What a layout ASKS FOR — never what it builds.
///
/// A specialization describes the surface it needs; the assembly is
/// what turns that description into an official structure. It is
/// SEALED, so the compiler admits exactly one description and a new
/// one cannot appear without the assembly learning to build it.
sealed class MentoraLayoutSurface {
  const MentoraLayoutSurface();

  /// One page: a place, its facets, the intention of finding inside
  /// it, what the person came to read, and the acts kept at hand.
  const factory MentoraLayoutSurface.page({
    required String semanticLabel,
    required Widget content,
    MentoraAppBar? place,
    MentoraTabs? facets,
    MentoraSearchBar? intention,
    List<MentoraButton> acts,
  }) = MentoraLayoutPageSurface;

  /// A room shared between regions, already built by the structure
  /// that owns it.
  const factory MentoraLayoutSurface.shared(MentoraSplitView workspace) =
      MentoraLayoutSharedSurface;

  /// Two spaces in relation, already built by the structure that owns
  /// it.
  const factory MentoraLayoutSurface.relation(MentoraMasterDetail relation) =
      MentoraLayoutRelationSurface;
}

final class MentoraLayoutPageSurface extends MentoraLayoutSurface {
  final String semanticLabel;
  final Widget content;
  final MentoraAppBar? place;
  final MentoraTabs? facets;
  final MentoraSearchBar? intention;
  final List<MentoraButton> acts;

  const MentoraLayoutPageSurface({
    required this.semanticLabel,
    required this.content,
    this.place,
    this.facets,
    this.intention,
    this.acts = const [],
  });
}

final class MentoraLayoutSharedSurface extends MentoraLayoutSurface {
  final MentoraSplitView workspace;

  const MentoraLayoutSharedSurface(this.workspace);
}

final class MentoraLayoutRelationSurface extends MentoraLayoutSurface {
  final MentoraMasterDetail relation;

  const MentoraLayoutRelationSurface(this.relation);
}

/// The single assembly of the whole Layout layer.
///
/// Every official layout of Mentora is assembled HERE, and nowhere
/// else. A specialization declares what makes it that layout — its
/// kind, the context it was handed and the surface it asks for — and
/// this one place builds the page, composes the working context, the
/// way through the product and the temporary layers.
///
/// Nothing else may do any of it: no layout creates a working context,
/// no layout creates a page, no layout mounts a layer. Scans prove it,
/// and the abstraction above makes it the only path.
final class MentoraLayoutAssembly extends StatelessWidget {
  /// Which official shape this screen takes. It is expressed as a key,
  /// so that a screen can always be recognised for what it is.
  final MentoraLayoutKind kind;

  /// What every layout is handed — the same contract for all of them.
  final MentoraLayoutContext frame;

  /// The surface the layout asked for.
  final MentoraLayoutSurface surface;

  const MentoraLayoutAssembly({
    super.key,
    required this.kind,
    required this.frame,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return MentoraWorkspace(
      key: Key('layout-${kind.name}'),
      semanticLabel: frame.semanticLabel,
      configuration: frame.configuration,
      navigation: frame.navigation,
      orientation: frame.orientation,
      rail: frame.rail,
      base: frame.base,
      dialogs: frame.dialogs,
      sheets: frame.sheets,
      messages: frame.messages,
      surface: _surfaceOf(surface),
    );
  }

  /// What a description becomes.
  ///
  /// The switch is exhaustive by construction: a new description will
  /// not compile until this one place knows how to build it.
  MentoraWorkspaceSurface _surfaceOf(MentoraLayoutSurface asked) {
    switch (asked) {
      case MentoraLayoutPageSurface():
        if (asked.semanticLabel.isEmpty) {
          throw StateError(
            'A page announces the context it gathers: without a name '
            'it gathers nothing.',
          );
        }
        return MentoraWorkspaceSurface.page(
          MentoraPageScaffold(
            semanticLabel: asked.semanticLabel,
            place: asked.place,
            facets: asked.facets,
            intention: asked.intention,
            acts: asked.acts,
            content: asked.content,
          ),
        );
      case MentoraLayoutSharedSurface(:final workspace):
        return MentoraWorkspaceSurface.shared(workspace);
      case MentoraLayoutRelationSurface(:final relation):
        return MentoraWorkspaceSurface.relation(relation);
    }
  }
}
