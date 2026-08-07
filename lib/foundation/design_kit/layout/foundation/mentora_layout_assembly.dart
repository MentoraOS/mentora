import 'package:flutter/widgets.dart';

import '../../components/button/mentora_button.dart';
import '../../components/design_kit_scope.dart';
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
import 'mentora_layout_style.dart';
import 'mentora_layout_theme.dart';

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

  /// One page whose content is a set of NAMED REGIONS, read in the
  /// order they were announced, with nothing added between them.
  ///
  /// It is the single disposition of the layer: every layout that
  /// disposes named content asks for this, and none of them ever
  /// arranges regions itself.
  const factory MentoraLayoutSurface.regions({
    required String semanticLabel,
    required List<MentoraContentRegion> regions,
    MentoraAppBar? place,
    MentoraTabs? facets,
    MentoraSearchBar? intention,
    List<MentoraButton> acts,
  }) = MentoraLayoutRegionsSurface;

  /// One page whose content is a COLLECTION: a logical sequence of
  /// elements, read in the order they were announced, with nothing
  /// added between them.
  ///
  /// Only the collection is announced. Each element keeps its own
  /// voice, its own identity and its own semantics: the layer never
  /// speaks in their place.
  const factory MentoraLayoutSurface.collection({
    required String semanticLabel,
    required String collectionId,
    required String collectionSemanticLabel,
    required List<MentoraListItem> items,
    MentoraAppBar? place,
    MentoraTabs? facets,
    MentoraSearchBar? intention,
    List<MentoraButton> acts,
  }) = MentoraLayoutCollectionSurface;

  /// A room shared between regions, already built by the structure
  /// that owns it.
  const factory MentoraLayoutSurface.shared(MentoraSplitView workspace) =
      MentoraLayoutSharedSurface;

  /// Two spaces in relation, already built by the structure that owns
  /// it.
  const factory MentoraLayoutSurface.relation(MentoraMasterDetail relation) =
      MentoraLayoutRelationSurface;
}

/// What every page-shaped surface carries, whatever it is filled with.
sealed class MentoraLayoutPageLikeSurface extends MentoraLayoutSurface {
  final String semanticLabel;
  final MentoraAppBar? place;
  final MentoraTabs? facets;
  final MentoraSearchBar? intention;
  final List<MentoraButton> acts;

  const MentoraLayoutPageLikeSurface({
    required this.semanticLabel,
    this.place,
    this.facets,
    this.intention,
    this.acts = const [],
  });
}

final class MentoraLayoutPageSurface extends MentoraLayoutPageLikeSurface {
  final Widget content;

  const MentoraLayoutPageSurface({
    required super.semanticLabel,
    required this.content,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });
}

final class MentoraLayoutRegionsSurface extends MentoraLayoutPageLikeSurface {
  final List<MentoraContentRegion> regions;

  const MentoraLayoutRegionsSurface({
    required super.semanticLabel,
    required this.regions,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });
}

final class MentoraLayoutCollectionSurface
    extends MentoraLayoutPageLikeSurface {
  final String collectionId;
  final String collectionSemanticLabel;
  final List<MentoraListItem> items;

  const MentoraLayoutCollectionSurface({
    required super.semanticLabel,
    required this.collectionId,
    required this.collectionSemanticLabel,
    required this.items,
    super.place,
    super.facets,
    super.intention,
    super.acts,
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
    final theme = MentoraLayoutTheme.fromScope(DesignKitScope.of(context));

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
      surface: _surfaceOf(surface, theme),
    );
  }

  /// What a description becomes.
  ///
  /// The switch is exhaustive by construction: a new description will
  /// not compile until this one place knows how to build it.
  MentoraWorkspaceSurface _surfaceOf(
    MentoraLayoutSurface asked,
    MentoraLayoutTheme theme,
  ) {
    switch (asked) {
      case MentoraLayoutPageSurface():
        return MentoraWorkspaceSurface.page(
          _page(asked, content: asked.content),
        );
      case MentoraLayoutRegionsSurface():
        return MentoraWorkspaceSurface.page(
          _page(
            asked,
            content: Column(
              key: const Key('content-regions'),
              // The room the layer adds between the regions it was
              // handed: none, and it is a Token so that the none is
              // opposable rather than assumed.
              spacing: theme.contentGap,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final region in asked.regions) _region(region)],
            ),
          ),
        );
      case MentoraLayoutCollectionSurface():
        return MentoraWorkspaceSurface.page(
          _page(asked, content: _collection(asked, theme)),
        );
      case MentoraLayoutSharedSurface(:final workspace):
        return MentoraWorkspaceSurface.shared(workspace);
      case MentoraLayoutRelationSurface(:final relation):
        return MentoraWorkspaceSurface.relation(relation);
    }
  }

  /// The official page, built here and nowhere else.
  MentoraPageScaffold _page(
    MentoraLayoutPageLikeSurface asked, {
    required Widget content,
  }) {
    if (asked.semanticLabel.isEmpty) {
      throw StateError(
        'A page announces the context it gathers: without a name it '
        'gathers nothing.',
      );
    }
    return MentoraPageScaffold(
      semanticLabel: asked.semanticLabel,
      place: asked.place,
      facets: asked.facets,
      intention: asked.intention,
      acts: asked.acts,
      content: content,
    );
  }

  /// One collection: a single landmark, one focus group, and the
  /// elements in the order they were announced.
  ///
  /// Nothing is added between them, nothing separates them, and
  /// nothing is said about them: an element keeps its own voice.
  Widget _collection(
    MentoraLayoutCollectionSurface asked,
    MentoraLayoutTheme theme,
  ) {
    return Semantics(
      key: Key('list-${asked.collectionId}'),
      container: true,
      explicitChildNodes: true,
      label: asked.collectionSemanticLabel,
      // A collection travels as one focus group: moving through it
      // follows its elements, and never wanders out of it.
      child: FocusTraversalGroup(
        child: Column(
          key: Key('list-items-${asked.collectionId}'),
          // The room the layer adds between the elements it was
          // handed: none, and it is a Token so that the none is
          // opposable rather than assumed.
          spacing: theme.contentGap,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in asked.items)
              KeyedSubtree(
                key: Key('list-item-${item.id}'),
                child: item.content,
              ),
          ],
        ),
      ),
    );
  }

  /// One region: a named landmark, its own focus group, and what it
  /// carries — handed on exactly as it was given.
  Widget _region(MentoraContentRegion region) {
    return Semantics(
      key: Key('content-region-${region.id}'),
      container: true,
      explicitChildNodes: true,
      label: region.semanticLabel,
      // Each region travels as its own focus group: reading a page
      // follows its regions, and never wanders between them.
      child: FocusTraversalGroup(child: region.content),
    );
  }
}
