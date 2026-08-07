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

/// The official List Layout - the way a collection is presented in
/// Mentora.
///
/// A list is not a ListView, not a scroll view, not a Flutter
/// collection, not a sliver and not a virtualization. It is a logical
/// SEQUENCE of elements: an identity, elements already built, the
/// order they were announced in, and one announcement for the whole.
///
/// It expresses. It never decides.
///
/// It scrolls nothing, paginates nothing, loads nothing lazily,
/// separates nothing, measures nothing and adds no room. The order is
/// announced - never computed, never sorted, never filtered, never
/// reversed, never grouped. And it never speaks in an element's place:
/// each of them keeps its own voice, its own identity and its own
/// semantics.
///
/// It builds nothing at all: it describes the collection, and the
/// assembly of the layer is what places it.
final class MentoraListLayout extends MentoraLayout {
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

  /// What this collection IS - stable forever, never a position.
  final String listId;

  /// What the screen reader hears about the collection itself, and
  /// about it alone.
  final String listSemanticLabel;

  /// The elements, in the order they are to be read.
  final List<MentoraListItem> items;

  /// What the screen reader hears about the page itself.
  final String pageSemanticLabel;

  const MentoraListLayout({
    super.key,
    required this.frame,
    required this.listId,
    required this.listSemanticLabel,
    required this.items,
    required this.pageSemanticLabel,
    this.place,
    this.facets,
    this.intention,
    this.acts = const [],
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.list;

  @override
  void verify() {
    if (listId.isEmpty) {
      throw StateError('A collection without an identity is not one.');
    }
    if (listSemanticLabel.isEmpty) {
      throw StateError(
        'A collection without a name is not a landmark: a person '
        'always knows which collection they are reading.',
      );
    }
    if (items.isEmpty) {
      throw StateError(
        'A collection presents elements: without one it presents '
        'nothing, and nothing is not a collection.',
      );
    }
    final identities = <String>{};
    for (final item in items) {
      if (item.id.isEmpty) {
        throw StateError('An element without an identity is not one.');
      }
      if (!identities.add(item.id)) {
        throw StateError('Two elements never share one identity.');
      }
    }
  }

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    return MentoraLayoutSurface.collection(
      semanticLabel: pageSemanticLabel,
      place: place,
      facets: facets,
      intention: intention,
      acts: acts,
      collectionId: listId,
      collectionSemanticLabel: listSemanticLabel,
      items: items,
    );
  }
}
