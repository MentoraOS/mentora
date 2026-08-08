import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';
import '../foundation/mentora_principal_layout.dart';

/// The official Feed Layout — the way a screen where a person goes
/// through a succession of elements is organised.
///
/// It never shows what is in the flow. It shows a PERSON GOING THROUGH
/// one: what they are about to go through, what must be known first,
/// THE FLOW ITSELF, what helps beside it, what can be done on the whole
/// of it, and what is said underneath.
///
/// It represents no domain of the company, and it never will: the same
/// shape carries whatever succession the application is showing,
/// because the shape is about the act of going through and not about
/// what is gone through.
///
/// It expresses. It never decides.
///
/// It knows no data, no logic, no calculation, no ordering, no grouping,
/// no paging, no network, no state of the flow and no platform. It
/// makes no room of its own and no way of moving through anything: what
/// a succession IS belongs to the List Layout, what an element IS
/// belongs to the components, and the way through belongs to whoever
/// the application hands the flow to. It owns no order, no identity and
/// no refusal either: the principal foundation owns them, once, for
/// every shape built around one matter.
///
/// The flow itself is the only region a feed cannot do without, and the
/// compiler says so: it is not optional.
final class MentoraFeedLayout extends MentoraPrincipalLayout {
  const MentoraFeedLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required MentoraLayoutZone feed,
    super.header,
    super.introduction,
    super.supportingContent,
    super.actions,
    super.footer,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  }) : super(principal: feed);

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.feed;

  /// The flow itself — the word this shape calls its principal matter
  /// by. It is an alias, never a second field.
  MentoraLayoutZone get feed => principal;
}
