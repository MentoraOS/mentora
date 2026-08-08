import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';
import '../foundation/mentora_zoned_layout.dart';

/// The official Form Layout - the way the work of a person filling
/// information in is organised.
///
/// A form layout is NOT a form. The form belongs to the components:
/// MentoraInput owns what is typed, MentoraButton owns the acts,
/// MentoraText owns the words, MentoraSection owns the sections. What
/// this layout owns is the CONTEXT of that work: its regions, their
/// order, their announcements and their focus groups.
///
/// It expresses. It never decides.
///
/// It validates nothing, submits nothing, knows no field, no data, no
/// model, no network, no platform and no state of the work. It builds
/// nothing either: it speaks the official vocabulary of a form, and the
/// zoned foundation is what turns it into regions.
///
/// The work itself is the only region a form cannot do without, and
/// the compiler says so: it is not optional.
final class MentoraFormLayout extends MentoraZonedLayout<MentoraFormRegion> {
  /// What the person is about to do.
  final MentoraLayoutZone? header;

  /// What must be known before filling anything in.
  final MentoraLayoutZone? introduction;

  /// The work itself. A form without it is not a form, and this is
  /// refused by the type rather than at run time.
  final MentoraLayoutZone form;

  /// What helps while filling it in.
  final MentoraLayoutZone? supportingContent;

  /// What closes the work.
  final MentoraLayoutZone? actions;

  /// What is said under everything.
  final MentoraLayoutZone? footer;

  const MentoraFormLayout({
    super.key,
    required super.frame,
    required this.form,
    required super.pageSemanticLabel,
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
  MentoraLayoutKind get kind => MentoraLayoutKind.form;

  @override
  List<MentoraFormRegion> get vocabulary => MentoraFormRegion.values;

  @override
  Map<MentoraFormRegion, MentoraLayoutZone?> get zones => {
    MentoraFormRegion.header: header,
    MentoraFormRegion.introduction: introduction,
    MentoraFormRegion.form: form,
    MentoraFormRegion.supportingContent: supportingContent,
    MentoraFormRegion.actions: actions,
    MentoraFormRegion.footer: footer,
  };
}
