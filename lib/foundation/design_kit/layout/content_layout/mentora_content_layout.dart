import 'package:flutter/widgets.dart';

import '../../components/button/mentora_button.dart';
import '../../components/design_kit_scope.dart';
import '../../structure/app_bar/mentora_app_bar.dart';
import '../../structure/search_bar/mentora_search_bar.dart';
import '../../structure/tabs/mentora_tabs.dart';
import '../foundation/mentora_layout.dart';
import '../foundation/mentora_layout_assembly.dart';
import '../foundation/mentora_layout_context.dart';
import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';
import '../foundation/mentora_layout_theme.dart';

/// The official Content Layout — the way content is disposed in
/// Mentora.
///
/// It is not a page, not a screen, not a dashboard, not a grid and not
/// a list. It is the official disposition of content that is ALREADY
/// BUILT: named regions, read in the order the application announced
/// them, each one a landmark of its own and its own focus group.
///
/// What it owns is the ORDER and the ANNOUNCEMENT. What it never owns
/// is the room: it creates no padding, no spacing, no scroll view. It
/// adds nothing at all between what it was handed — the absence is a
/// Token, so that it is opposable rather than assumed — and it hands
/// every region on strictly intact.
///
/// The parent announces. The layout expresses. Always.
final class MentoraContentLayout extends MentoraLayout {
  @override
  final MentoraLayoutContext frame;

  /// Where the person is — the App Bar remains its owner.
  final MentoraAppBar? place;

  /// The facets of the page — the Tabs remain their owner.
  final MentoraTabs? facets;

  /// The intention of finding — the Search Bar remains its owner.
  final MentoraSearchBar? intention;

  /// The acts the page keeps at hand — the Button remains their owner.
  final List<MentoraButton> acts;

  /// The regions of content, in the order they are to be read.
  final List<MentoraContentRegion> regions;

  /// What the screen reader hears about the page itself.
  final String pageSemanticLabel;

  const MentoraContentLayout({
    super.key,
    required this.frame,
    required this.regions,
    required this.pageSemanticLabel,
    this.place,
    this.facets,
    this.intention,
    this.acts = const [],
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.content;

  @override
  void verify() {
    if (regions.isEmpty) {
      throw StateError(
        'A content layout disposes content: without a region it '
        'disposes nothing, and nothing is not a disposition.',
      );
    }
    final identities = <String>{};
    for (final region in regions) {
      if (region.id.isEmpty) {
        throw StateError('A region without an identity is not a region.');
      }
      if (region.semanticLabel.isEmpty) {
        throw StateError(
          'A region without a name is not a landmark: a person always '
          'knows which region they are reading.',
        );
      }
      if (!identities.add(region.id)) {
        throw StateError('Two regions never share one identity.');
      }
    }
  }

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    final theme = MentoraLayoutTheme.fromScope(DesignKitScope.of(context));

    return MentoraLayoutSurface.page(
      semanticLabel: pageSemanticLabel,
      place: place,
      facets: facets,
      intention: intention,
      acts: acts,
      content: Column(
        key: const Key('content-regions'),
        // The room a layout adds between the regions it was handed:
        // none, and it is a Token so that the none is opposable.
        spacing: theme.contentGap,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final region in regions) _region(region)],
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
