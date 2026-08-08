import '../../components/button/mentora_button.dart';
import '../../structure/app_bar/mentora_app_bar.dart';
import '../../structure/search_bar/mentora_search_bar.dart';
import '../../structure/tabs/mentora_tabs.dart';
import 'mentora_layout.dart';
import 'mentora_layout_context.dart';

/// What every layout SHAPED AS A PAGE is handed.
///
/// A page is a place a person is in: it announces itself, it may say
/// where that place stands in the product, which facets of it exist,
/// that one may look for something inside it, and which acts it keeps
/// at hand. Those five parts belong to no particular shape — a page of
/// content, a page of sections, a page of cells and a page built around
/// one matter are handed exactly the same ones.
///
/// So they are declared HERE, once. Before this foundation existed the
/// same five fields, with the same doc comments, were written in every
/// page-shaped specialization: seven copies of one paragraph, each free
/// to drift from the others. There is now nothing left to drift.
///
/// It decides nothing and refuses nothing of its own: what a page owes
/// is verified where a page is built — the single assembly. A shape
/// built on it adds only what makes it that shape.
abstract base class MentoraPageLikeLayout extends MentoraLayout {
  @override
  final MentoraLayoutContext frame;

  /// What the screen reader hears about the page itself.
  final String pageSemanticLabel;

  /// Where the person is — the App Bar remains its owner.
  final MentoraAppBar? place;

  /// The facets of the page — the Tabs remain their owner.
  final MentoraTabs? facets;

  /// The intention of finding — the Search Bar remains its owner.
  final MentoraSearchBar? intention;

  /// The acts the page keeps at hand — the Button remains their owner.
  final List<MentoraButton> acts;

  const MentoraPageLikeLayout({
    super.key,
    required this.frame,
    required this.pageSemanticLabel,
    this.place,
    this.facets,
    this.intention,
    this.acts = const [],
  });
}
