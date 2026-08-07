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

/// The official Tabbed Content Layout - several contents of one
/// context, of which exactly one is revealed.
///
/// It is not a tab bar, not a tab view, not a page view, not a
/// navigator, not a screen and not a navigation. It is one CONTEXT
/// holding several contents already decided, and the announcement of
/// the one that is revealed right now.
///
/// It expresses. It never decides.
///
/// It changes no tab, navigates nowhere, computes nothing, measures
/// nothing, scrolls nothing and adds no room. The facets belong to
/// MentoraTabs, which it composes and never recreates. What is not
/// revealed is not built: it exists neither in the tree, nor for the
/// focus, nor for a screen reader.
///
/// It builds nothing at all: it describes the context, and the
/// assembly of the layer is what reveals it.
final class MentoraTabbedContentLayout extends MentoraLayout {
  @override
  final MentoraLayoutContext frame;

  /// The facets of the context - the Tabs remain their owner, and a
  /// context without them is not a tabbed context.
  final MentoraTabs facets;

  /// Where the person is - the App Bar remains its owner.
  final MentoraAppBar? place;

  /// The intention of finding - the Search Bar remains its owner.
  final MentoraSearchBar? intention;

  /// The acts the page keeps at hand - the Button remains their owner.
  final List<MentoraButton> acts;

  /// What this context IS - stable forever, never a position.
  final String contextId;

  /// What the screen reader hears about the context itself, and about
  /// it alone.
  final String contextSemanticLabel;

  /// The contents of the context, already built.
  final List<MentoraIdentifiedContent> contents;

  /// Which content is revealed right now. The application announces
  /// it; the context never chooses it.
  final String revealedContentId;

  /// What the screen reader hears about the page itself.
  final String pageSemanticLabel;

  const MentoraTabbedContentLayout({
    super.key,
    required this.frame,
    required this.facets,
    required this.contextId,
    required this.contextSemanticLabel,
    required this.contents,
    required this.revealedContentId,
    required this.pageSemanticLabel,
    this.place,
    this.intention,
    this.acts = const [],
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.tabbedContent;

  @override
  void verify() {
    if (contextId.isEmpty) {
      throw StateError('A context without an identity is not one.');
    }
    if (contextSemanticLabel.isEmpty) {
      throw StateError(
        'A context without a name is not a landmark: a person always '
        'knows which context they are in.',
      );
    }
    if (contents.isEmpty) {
      throw StateError(
        'A context holds contents: without one it holds nothing, and '
        'nothing is not a context.',
      );
    }
    if (revealedContentId.isEmpty) {
      throw StateError(
        'A context is told what it reveals: an empty identity reveals '
        'nothing.',
      );
    }
    final identities = <String>{};
    for (final content in contents) {
      if (content.id.isEmpty) {
        throw StateError('A content without an identity is not one.');
      }
      if (!identities.add(content.id)) {
        throw StateError('Two contents never share one identity.');
      }
    }
    if (!identities.contains(revealedContentId)) {
      throw StateError(
        'The content announced as revealed is not one this context '
        'holds: a context never guesses what to show.',
      );
    }
  }

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    return MentoraLayoutSurface.revealed(
      semanticLabel: pageSemanticLabel,
      place: place,
      facets: facets,
      intention: intention,
      acts: acts,
      contextId: contextId,
      contextSemanticLabel: contextSemanticLabel,
      contents: contents,
      revealedContentId: revealedContentId,
    );
  }
}
