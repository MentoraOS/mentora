import '../foundation/mentora_collected_layout.dart';
import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';

/// The official Timeline Layout — the form of a succession of moments.
///
/// It is not a calendar, not a date, not an hour and not a computed
/// chronology. It is a COLLECTION of moments the application
/// announces: the timeline itself has an identity and a name, and each
/// moment is an identity and what it is — already built.
///
/// It expresses. It never decides.
///
/// The product announces the order; the shape respects it. It knows
/// nothing of when a moment happened: no instant, no zone, no
/// duration, no clock — a shape that understood its moments would have
/// decided something about them. What a moment shows belongs entirely
/// to the components, and the layer never speaks in its place.
///
/// It calculates nothing, compares nothing, groups nothing, pages
/// nothing and holds nothing back: the moments are read in the order
/// they were announced, all of them, every time.
///
/// It builds nothing at all, and it owns no identity, no refusal and
/// no surface: the collected foundation owns them, once, for every
/// shape that presents a collection. What this shape declares is its
/// official kind, and the words a succession of moments uses for what
/// it presents — aliases over the one holder, never second fields.
final class MentoraTimelineLayout extends MentoraCollectedLayout {
  const MentoraTimelineLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required String timelineId,
    required String timelineSemanticLabel,
    required List<MentoraIdentifiedContent> moments,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  }) : super(
         collectionId: timelineId,
         collectionSemanticLabel: timelineSemanticLabel,
         contents: moments,
       );

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.timeline;

  /// What this timeline IS — the word this shape calls its collection
  /// by. It is an alias, never a second field.
  String get timelineId => collectionId;

  /// What the screen reader hears about the timeline itself.
  String get timelineSemanticLabel => collectionSemanticLabel;

  /// The moments, in the order they were announced.
  List<MentoraIdentifiedContent> get moments => contents;
}
