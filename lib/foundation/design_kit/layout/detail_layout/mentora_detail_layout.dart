import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';
import '../foundation/mentora_zoned_layout.dart';

/// The official Detail Layout — the way a screen where a person
/// consults ONE thing is organised.
///
/// It never shows a thing. It shows a PERSON CONSULTING a thing: what
/// they see first, what the thing is, what is essential about it, what
/// is known about it at length, what helps beside it, what can be done
/// about it, and what is said underneath.
///
/// It represents no domain of the company, and it never will: the same
/// shape carries whatever the application is consulting, because the
/// shape is about the act of consulting and not about what is consulted.
///
/// It expresses. It never decides.
///
/// It knows no data, no logic, no calculation, no ordering, no network,
/// no state of what is being consulted and no platform. It builds
/// nothing either — MentoraAvatar, MentoraCard, MentoraBadge,
/// MentoraButton, MentoraSection and MentoraText remain the owners of
/// everything it is handed. It speaks the official vocabulary of a
/// detail, and the zoned foundation is what turns it into regions.
///
/// Every region is optional, but a detail informs: at least one of the
/// regions the vocabulary declares as informing must be given, or the
/// shape refuses to build — fail closed.
final class MentoraDetailLayout
    extends MentoraZonedLayout<MentoraDetailRegion> {
  /// What one sees first of the thing consulted.
  final MentoraLayoutZone? hero;

  /// What the thing IS.
  final MentoraLayoutZone? identity;

  /// What is essential about it, said shortly.
  final MentoraLayoutZone? summary;

  /// Everything that is known about it, at length.
  final MentoraLayoutZone? details;

  /// What helps beside it, without being about it.
  final MentoraLayoutZone? supportingContent;

  /// What can be done about it.
  final MentoraLayoutZone? actions;

  /// What is said under everything.
  final MentoraLayoutZone? footer;

  const MentoraDetailLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    this.hero,
    this.identity,
    this.summary,
    this.details,
    this.supportingContent,
    this.actions,
    this.footer,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.detail;

  @override
  List<MentoraDetailRegion> get vocabulary => MentoraDetailRegion.values;

  @override
  Map<MentoraDetailRegion, MentoraLayoutZone?> get zones => {
    MentoraDetailRegion.hero: hero,
    MentoraDetailRegion.identity: identity,
    MentoraDetailRegion.summary: summary,
    MentoraDetailRegion.details: details,
    MentoraDetailRegion.supportingContent: supportingContent,
    MentoraDetailRegion.actions: actions,
    MentoraDetailRegion.footer: footer,
  };

  @override
  void verifyZones() {
    final given = zones;
    for (final region in vocabulary) {
      if (!region.carriesInformation) continue;
      if (given[region] != null) return;
    }
    throw StateError(
      'A detail informs about the thing it shows: without any of the '
      'regions that inform, a person consults nothing.',
    );
  }
}
