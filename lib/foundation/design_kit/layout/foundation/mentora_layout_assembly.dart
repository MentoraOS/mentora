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
    required List<MentoraIdentifiedContent> items,
    MentoraAppBar? place,
    MentoraTabs? facets,
    MentoraSearchBar? intention,
    List<MentoraButton> acts,
  }) = MentoraLayoutCollectionSurface;

  /// One page whose content is a GRID: cells standing exactly where
  /// the application announced them, with nothing added between them.
  ///
  /// Only the grid is announced. Each cell keeps its own voice, its
  /// own identity and its own semantics.
  const factory MentoraLayoutSurface.grid({
    required String semanticLabel,
    required String gridId,
    required String gridSemanticLabel,
    required MentoraGridDisposition disposition,
    MentoraAppBar? place,
    MentoraTabs? facets,
    MentoraSearchBar? intention,
    List<MentoraButton> acts,
  }) = MentoraLayoutGridSurface;

  /// One page whose content is one of SEVERAL contents of the same
  /// context — the one the application announced as revealed.
  ///
  /// The contents that are not revealed do not exist: they are not
  /// built, so nothing of them is placed, focusable or spoken.
  const factory MentoraLayoutSurface.revealed({
    required String semanticLabel,
    required String contextId,
    required String contextSemanticLabel,
    required List<MentoraIdentifiedContent> contents,
    required String revealedContentId,
    MentoraAppBar? place,
    MentoraTabs? facets,
    MentoraSearchBar? intention,
    List<MentoraButton> acts,
  }) = MentoraLayoutRevealedSurface;

  /// One page whose content is a CONFIGURATION SPACE: categories, each
  /// announced, each holding what is always there and what is there
  /// only while the application says that category is open.
  ///
  /// The `regions` disposition places ONE content per named part, so it
  /// cannot say what a configuration space says: that a part is
  /// announced whether it is open or not, and that what it holds does
  /// not exist while it is closed. That is why this description exists,
  /// and it is the only reason it does.
  const factory MentoraLayoutSurface.settings({
    required String semanticLabel,
    required List<MentoraSettingsCategory> categories,
    MentoraAppBar? place,
    MentoraTabs? facets,
    MentoraSearchBar? intention,
    List<MentoraButton> acts,
  }) = MentoraLayoutSettingsSurface;

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
  final List<MentoraIdentifiedContent> items;

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

final class MentoraLayoutGridSurface extends MentoraLayoutPageLikeSurface {
  final String gridId;
  final String gridSemanticLabel;
  final MentoraGridDisposition disposition;

  const MentoraLayoutGridSurface({
    required super.semanticLabel,
    required this.gridId,
    required this.gridSemanticLabel,
    required this.disposition,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });
}

final class MentoraLayoutRevealedSurface extends MentoraLayoutPageLikeSurface {
  final String contextId;
  final String contextSemanticLabel;
  final List<MentoraIdentifiedContent> contents;
  final String revealedContentId;

  const MentoraLayoutRevealedSurface({
    required super.semanticLabel,
    required this.contextId,
    required this.contextSemanticLabel,
    required this.contents,
    required this.revealedContentId,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });
}

final class MentoraLayoutSettingsSurface extends MentoraLayoutPageLikeSurface {
  final List<MentoraSettingsCategory> categories;

  const MentoraLayoutSettingsSurface({
    required super.semanticLabel,
    required this.categories,
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
    // A layout is a WHOLE SCREEN: it composes the working context, the
    // way through the product and the temporary layers. Placing one
    // inside another would open a second working context, a second set
    // of layers and a second landmark — so it is refused here, once,
    // rather than left to fail as a measure deep in the framework.
    if (context.dependOnInheritedWidgetOfExactType<_MentoraAssembledScreen>() !=
        null) {
      throw StateError(
        'A layout is a whole screen: it is never placed inside another. '
        'A region carries components, never a second screen.',
      );
    }

    final theme = MentoraLayoutTheme.fromScope(DesignKitScope.of(context));

    return _MentoraAssembledScreen(
      child: MentoraWorkspace(
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
      ),
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
            content: _stacked(
              key: const Key('content-regions'),
              theme: theme,
              children: [for (final region in asked.regions) _region(region)],
            ),
          ),
        );
      case MentoraLayoutCollectionSurface():
        return MentoraWorkspaceSurface.page(
          _page(asked, content: _collection(asked, theme)),
        );
      case MentoraLayoutGridSurface():
        return MentoraWorkspaceSurface.page(
          _page(asked, content: _grid(asked, theme)),
        );
      case MentoraLayoutRevealedSurface():
        return MentoraWorkspaceSurface.page(
          _page(asked, content: _revealed(asked)),
        );
      case MentoraLayoutSettingsSurface():
        return MentoraWorkspaceSurface.page(
          _page(asked, content: _settings(asked, theme)),
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
    return _announced(
      key: Key('list-${asked.collectionId}'),
      label: asked.collectionSemanticLabel,
      child: _stacked(
        key: Key('list-items-${asked.collectionId}'),
        theme: theme,
        children: [
          for (final item in asked.items)
            KeyedSubtree(key: Key('list-item-${item.id}'), child: item.content),
        ],
      ),
    );
  }

  /// One grid: a single landmark, one focus group, and the cells
  /// exactly where they were announced.
  ///
  /// Nothing is counted, nothing is deduced and nothing is adapted:
  /// the rows are the rows that were given, and every cell takes the
  /// room that was announced for it.
  Widget _grid(MentoraLayoutGridSurface asked, MentoraLayoutTheme theme) {
    return _announced(
      key: Key('grid-${asked.gridId}'),
      label: asked.gridSemanticLabel,
      child: _stacked(
        key: Key('grid-rows-${asked.gridId}'),
        theme: theme,
        children: [
          for (final row in asked.disposition.rows)
            Row(
              key: Key('grid-row-${row.id}'),
              spacing: theme.contentGap,
              mainAxisSize: MainAxisSize.min,
              // A cell keeps the height it has: a row never stretches
              // what it places beside something taller.
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final cell in row.cells)
                  SizedBox(
                    key: Key('grid-cell-${cell.id}'),
                    width: cell.extent,
                    child: cell.content,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  /// The one content that was announced as revealed.
  ///
  /// The context is announced once; the content revealed keeps its own
  /// voice. What is not revealed is never built, so it is not placed,
  /// not focusable and not spoken — it does not exist.
  Widget _revealed(MentoraLayoutRevealedSurface asked) {
    for (final content in asked.contents) {
      if (content.id != asked.revealedContentId) continue;
      return _announced(
        key: Key('tabbed-${asked.contextId}'),
        label: asked.contextSemanticLabel,
        child: KeyedSubtree(
          key: Key('tabbed-content-${content.id}'),
          child: content.content,
        ),
      );
    }
    throw StateError(
      'The content announced as revealed is not one this context '
      'holds: a context never guesses what to show.',
    );
  }

  /// One region: a named landmark, its own focus group, and what it
  /// carries — handed on exactly as it was given.
  Widget _region(MentoraContentRegion region) => _announced(
    key: Key('content-region-${region.id}'),
    label: region.semanticLabel,
    child: region.content,
  );

  /// One configuration space: every category announced, in the order
  /// they were given, and what a category holds built ONLY while the
  /// application says that category is open.
  ///
  /// A category that is closed is announced all the same: it keeps its
  /// landmark and what is always there. What it holds simply does not
  /// exist — it is not placed, not focusable and not spoken.
  Widget _settings(
    MentoraLayoutSettingsSurface asked,
    MentoraLayoutTheme theme,
  ) => _stacked(
    key: const Key('settings-categories'),
    theme: theme,
    children: [
      for (final category in asked.categories)
        _announced(
          key: Key('settings-category-${category.id}'),
          label: category.semanticLabel,
          child: _stacked(
            key: Key('settings-category-content-${category.id}'),
            theme: theme,
            children: [
              category.summary,
              if (category.unfolded) category.options,
            ],
          ),
        ),
    ],
  );

  /// What every landmark of this layer IS.
  ///
  /// A named part of a page is announced once, travels as its own
  /// focus group, and carries what it was handed — strictly intact.
  /// It is written here once: a region, a collection, a grid, a
  /// revealed context and a category are announced the very same way,
  /// so none of them can ever come to be announced differently.
  Widget _announced({
    required Key key,
    required String label,
    required Widget child,
  }) {
    return Semantics(
      key: key,
      container: true,
      explicitChildNodes: true,
      label: label,
      // What is announced travels as one focus group: moving through
      // it follows what it holds, and never wanders out of it.
      child: FocusTraversalGroup(child: child),
    );
  }

  /// What the layer adds between the things it was handed: NOTHING.
  ///
  /// The absence is a Token, so that it is opposable rather than
  /// assumed, and it is applied here once for every disposition of the
  /// layer — regions, elements, rows and categories alike.
  Widget _stacked({
    required Key key,
    required MentoraLayoutTheme theme,
    required List<Widget> children,
  }) {
    return Column(
      key: key,
      spacing: theme.contentGap,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// The mark a screen leaves behind it, so that a second one can be
/// recognised — and refused — the moment it is attempted.
///
/// It carries nothing and never notifies: its whole existence is to
/// make "a layout is a whole screen" an opposable rule rather than a
/// convention nobody can check.
final class _MentoraAssembledScreen extends InheritedWidget {
  const _MentoraAssembledScreen({required super.child});

  @override
  bool updateShouldNotify(_MentoraAssembledScreen oldWidget) => false;
}
