import '../foundation/mentora_collected_layout.dart';
import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';

/// The official Search Results Layout — the form of a collection of
/// results already found.
///
/// It is not a search. The seeking belongs to the product: how it was
/// looked for, what was looked for, where, when and how much happened
/// elsewhere, before, never here. What arrives is a COLLECTION the
/// application announces: the collection itself has an identity and a
/// name, and each result is an identity and what it is — already
/// built, already found.
///
/// It expresses. The product seeks.
///
/// It knows nothing of what a result answers: no question, no measure
/// of how well it answers, no rank among the others — a shape that
/// understood its results would have decided something about them.
/// What a result shows belongs entirely to the components, and the
/// layer never speaks in its place.
///
/// It filters nothing, orders nothing, pages nothing and holds
/// nothing back: the results are read in the order they were
/// announced, all of them, every time.
///
/// It builds nothing at all, and it owns no identity, no refusal and
/// no surface: the collected foundation owns them, once, for every
/// shape that presents a collection. What this shape declares is its
/// official kind, and the words a collection of results uses for what
/// it presents — aliases over the one holder, never second fields.
final class MentoraSearchResultsLayout extends MentoraCollectedLayout {
  const MentoraSearchResultsLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required String searchResultsId,
    required String searchResultsSemanticLabel,
    required List<MentoraIdentifiedContent> results,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  }) : super(
         collectionId: searchResultsId,
         collectionSemanticLabel: searchResultsSemanticLabel,
         contents: results,
       );

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.searchResults;

  /// What this collection of results IS — the word this shape calls
  /// its collection by. It is an alias, never a second field.
  String get searchResultsId => collectionId;

  /// What the screen reader hears about the collection of results.
  String get searchResultsSemanticLabel => collectionSemanticLabel;

  /// The results, in the order they were announced.
  List<MentoraIdentifiedContent> get results => contents;
}
