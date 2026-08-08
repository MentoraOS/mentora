import '../../structure/tabs/mentora_tabs.dart';
import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_revealed_layout.dart';

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
/// MentoraTabs, which it composes and never recreates - and a context
/// without them is not a tabbed context, which the compiler says
/// rather than a check at run time.
///
/// It builds nothing at all, and it owns no identity, no refusal and
/// no surface: the revealing foundation owns them, once, for every
/// shape that shows one thing among several.
final class MentoraTabbedContentLayout extends MentoraRevealedLayout {
  const MentoraTabbedContentLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required MentoraTabs facets,
    required super.contextId,
    required super.contextSemanticLabel,
    required super.contents,
    required super.revealedContentId,
    super.place,
    super.intention,
    super.acts,
  }) : super(facets: facets);

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.tabbedContent;
}
