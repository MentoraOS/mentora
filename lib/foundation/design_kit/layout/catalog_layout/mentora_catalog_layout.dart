import '../foundation/mentora_collected_layout.dart';
import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';

/// The official Catalog Layout — the form of a space where a person
/// goes through an offer.
///
/// It is not a shop, not a marketplace, not a search and not a list of
/// results. It is a COLLECTION of entries the application announces:
/// the catalog itself has an identity and a name, and each entry is an
/// identity and what it is — already built.
///
/// It expresses. It never decides.
///
/// It knows nothing of what an entry is about: no article, no amount,
/// no currency, no availability, no promotion — a shape that
/// understood its entries would have decided something about them.
/// What an entry shows belongs entirely to the components, and the
/// layer never speaks in its place.
///
/// It selects nothing, rearranges nothing, pages nothing and holds
/// nothing back: the entries are read in the order they were
/// announced, all of them, every time.
///
/// It builds nothing at all, and it owns no identity, no refusal and
/// no surface: the collected foundation owns them, once, for every
/// shape that presents a collection. What this shape declares is its
/// official kind, and the words an offer uses for what it presents —
/// aliases over the one holder, never second fields.
final class MentoraCatalogLayout extends MentoraCollectedLayout {
  const MentoraCatalogLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required String catalogId,
    required String catalogSemanticLabel,
    required List<MentoraIdentifiedContent> entries,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  }) : super(
         collectionId: catalogId,
         collectionSemanticLabel: catalogSemanticLabel,
         contents: entries,
       );

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.catalog;

  /// What this catalog IS — the word this shape calls its collection
  /// by. It is an alias, never a second field.
  String get catalogId => collectionId;

  /// What the screen reader hears about the catalog itself.
  String get catalogSemanticLabel => collectionSemanticLabel;

  /// The entries, in the order they were announced.
  List<MentoraIdentifiedContent> get entries => contents;
}
