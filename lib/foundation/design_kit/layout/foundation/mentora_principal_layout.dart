import 'mentora_layout_style.dart';
import 'mentora_zoned_layout.dart';

/// What a page built around ONE principal matter IS.
///
/// It is a zoned layout, and it speaks the one official vocabulary of
/// such a page: what the person is about to do, what must be known
/// first, THE MATTER ITSELF, what helps beside it, what concludes, and
/// what is said underneath.
///
/// The matter is the only region such a page cannot do without, and the
/// COMPILER says so: it is not optional, and no run-time check is
/// needed to refuse a page that is about nothing.
///
/// Everything a shape of this kind could own is owned here: the six
/// parts, the vocabulary, the map from the words to what was given. A
/// shape built on it therefore declares TWO things — which official
/// kind it is, and the word it calls its principal matter by. That word
/// is an alias, never a second field: there is one matter, and one
/// place where it is held.
abstract base class MentoraPrincipalLayout
    extends MentoraZonedLayout<MentoraPrincipalRegion> {
  /// What the person is about to do, or about to go through.
  final MentoraLayoutZone? header;

  /// What must be known before anything else.
  final MentoraLayoutZone? introduction;

  /// The matter itself: the reason the page exists.
  final MentoraLayoutZone principal;

  /// What helps beside the matter, without being it.
  final MentoraLayoutZone? supportingContent;

  /// What concludes.
  final MentoraLayoutZone? actions;

  /// What is said under everything.
  final MentoraLayoutZone? footer;

  const MentoraPrincipalLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required this.principal,
    this.header,
    this.introduction,
    this.supportingContent,
    this.actions,
    this.footer,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });

  @override
  List<MentoraPrincipalRegion> get vocabulary => MentoraPrincipalRegion.values;

  @override
  Map<MentoraPrincipalRegion, MentoraLayoutZone?> get zones => {
    MentoraPrincipalRegion.header: header,
    MentoraPrincipalRegion.introduction: introduction,
    MentoraPrincipalRegion.principal: principal,
    MentoraPrincipalRegion.supportingContent: supportingContent,
    MentoraPrincipalRegion.actions: actions,
    MentoraPrincipalRegion.footer: footer,
  };
}
