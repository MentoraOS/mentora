import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';
import '../foundation/mentora_principal_layout.dart';

/// The official Form Layout - the way the work of a person filling
/// information in is organised.
///
/// A form layout is NOT a form. The form belongs to the components:
/// MentoraInput owns what is typed, MentoraButton owns the acts,
/// MentoraText owns the words, MentoraSection owns the sections. What
/// this layout owns is the CONTEXT of that work: nothing more than the
/// official kind it is, and the word this shape calls its principal
/// matter by - the work itself.
///
/// It expresses. It never decides.
///
/// It validates nothing, submits nothing, knows no field, no data, no
/// model, no network, no platform and no state of the work. It builds
/// nothing either, and it owns no order, no identity and no refusal:
/// the principal foundation owns them, once, for every shape built
/// around one matter.
///
/// The work itself is the only region a form cannot do without, and
/// the compiler says so: it is not optional.
final class MentoraFormLayout extends MentoraPrincipalLayout {
  const MentoraFormLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required MentoraLayoutZone form,
    super.header,
    super.introduction,
    super.supportingContent,
    super.actions,
    super.footer,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  }) : super(principal: form);

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.form;

  /// The work itself - the word this shape calls its principal matter
  /// by. It is an alias, never a second field.
  MentoraLayoutZone get form => principal;
}
