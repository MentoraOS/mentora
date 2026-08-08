import '../foundation/mentora_collected_layout.dart';
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
/// separates nothing, measures nothing and adds no room. And it never
/// speaks in an element's place: each of them keeps its own voice, its
/// own identity and its own semantics.
///
/// It builds nothing at all, and it owns no identity, no refusal and
/// no surface: the collected foundation owns them, once, for every
/// shape that presents a collection. What this shape declares is its
/// official kind, and the words a list uses for what it presents -
/// aliases over the one holder, never second fields.
final class MentoraListLayout extends MentoraCollectedLayout {
  const MentoraListLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required String listId,
    required String listSemanticLabel,
    required List<MentoraIdentifiedContent> items,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  }) : super(
         collectionId: listId,
         collectionSemanticLabel: listSemanticLabel,
         contents: items,
       );

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.list;

  /// What this list IS - the word this shape calls its collection by.
  /// It is an alias, never a second field.
  String get listId => collectionId;

  /// What the screen reader hears about the list itself.
  String get listSemanticLabel => collectionSemanticLabel;

  /// The elements, in the order they were announced.
  List<MentoraIdentifiedContent> get items => contents;
}
