import 'package:flutter/widgets.dart';

import '../../components/button/mentora_button.dart';
import '../../structure/app_bar/mentora_app_bar.dart';
import '../../structure/search_bar/mentora_search_bar.dart';
import '../../structure/tabs/mentora_tabs.dart';
import '../foundation/mentora_layout.dart';
import '../foundation/mentora_layout_assembly.dart';
import '../foundation/mentora_layout_context.dart';
import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';

/// The official Grid Layout - the way a spatial collection is
/// presented in Mentora.
///
/// A grid is not a grid view, not a wrap, not a flow, not a sliver
/// grid and not a responsive layout. It is a spatial collection
/// ALREADY DECIDED: an identity, cells already built, a disposition
/// already announced, and one announcement for the whole.
///
/// It expresses. It never decides.
///
/// It counts no column and no row, deduces nothing, adapts nothing,
/// measures nothing, scrolls nothing and adds no room. And it never
/// speaks in a cell place: each of them keeps its own voice, its own
/// identity and its own semantics.
///
/// It builds nothing at all: it describes the grid, and the assembly
/// of the layer is what places it.
final class MentoraGridLayout extends MentoraLayout {
  @override
  final MentoraLayoutContext frame;

  /// Where the person is - the App Bar remains its owner.
  final MentoraAppBar? place;

  /// The facets of the page - the Tabs remain their owner.
  final MentoraTabs? facets;

  /// The intention of finding - the Search Bar remains its owner.
  final MentoraSearchBar? intention;

  /// The acts the page keeps at hand - the Button remains their owner.
  final List<MentoraButton> acts;

  /// What this grid IS - stable forever, never a position.
  final String gridId;

  /// What the screen reader hears about the grid itself, and about it
  /// alone.
  final String gridSemanticLabel;

  /// Where every cell stands, already decided by the application.
  final MentoraGridDisposition disposition;

  /// What the screen reader hears about the page itself.
  final String pageSemanticLabel;

  const MentoraGridLayout({
    super.key,
    required this.frame,
    required this.gridId,
    required this.gridSemanticLabel,
    required this.disposition,
    required this.pageSemanticLabel,
    this.place,
    this.facets,
    this.intention,
    this.acts = const [],
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.grid;

  @override
  void verify() {
    if (gridId.isEmpty) {
      throw StateError('A grid without an identity is not one.');
    }
    if (gridSemanticLabel.isEmpty) {
      throw StateError(
        'A grid without a name is not a landmark: a person always '
        'knows which grid they are reading.',
      );
    }
    disposition.verify();
  }

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    return MentoraLayoutSurface.grid(
      semanticLabel: pageSemanticLabel,
      place: place,
      facets: facets,
      intention: intention,
      acts: acts,
      gridId: gridId,
      gridSemanticLabel: gridSemanticLabel,
      disposition: disposition,
    );
  }
}
