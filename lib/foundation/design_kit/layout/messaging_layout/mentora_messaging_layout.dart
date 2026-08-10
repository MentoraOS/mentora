import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';
import '../foundation/mentora_zoned_layout.dart';

/// The official Messaging Layout — the way a conversation space is
/// organised.
///
/// It is not a chat, not a delivery, not a presence and not a
/// protocol. It never talks: it shows a PERSON IN A DIALOGUE the
/// product already holds — what stands above the dialogue, the
/// dialogue itself, the place where they compose, what helps beside
/// it, and what is said underneath.
///
/// It expresses. The product dialogues.
///
/// It knows no words of the dialogue, no one who speaks them, no
/// moment they were spoken at, and no way they travel: what a region
/// shows belongs entirely to the components and to the application,
/// and the layer never speaks in their place. It speaks the official
/// vocabulary of a conversation space, and the zoned foundation is
/// what turns it into regions.
///
/// The dialogue is the only region such a space cannot do without, and
/// the COMPILER says so: it is not optional, and no run-time check is
/// needed to refuse a space that converses about nothing. The place
/// where a person composes is optional: a space may only be read, and
/// it is a conversation space still.
final class MentoraMessagingLayout
    extends MentoraZonedLayout<MentoraMessagingRegion> {
  /// What stands above the dialogue, and frames it.
  final MentoraLayoutZone? header;

  /// The dialogue itself: the reason the space exists.
  final MentoraLayoutZone conversation;

  /// Where the person composes what they will say next.
  final MentoraLayoutZone? composition;

  /// What helps beside the dialogue, without being it.
  final MentoraLayoutZone? supportingContent;

  /// What is said under everything.
  final MentoraLayoutZone? footer;

  const MentoraMessagingLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required this.conversation,
    this.header,
    this.composition,
    this.supportingContent,
    this.footer,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.messaging;

  @override
  List<MentoraMessagingRegion> get vocabulary => MentoraMessagingRegion.values;

  @override
  Map<MentoraMessagingRegion, MentoraLayoutZone?> get zones => {
    MentoraMessagingRegion.header: header,
    MentoraMessagingRegion.conversation: conversation,
    MentoraMessagingRegion.composition: composition,
    MentoraMessagingRegion.supportingContent: supportingContent,
    MentoraMessagingRegion.footer: footer,
  };
}
