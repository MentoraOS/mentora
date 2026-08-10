import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';
import '../foundation/mentora_principal_layout.dart';

/// The official Authentication Layout — the way the page where a
/// person proves who they are is organised.
///
/// It authenticates no one. The proving belongs to the product: what
/// is presented, how it is examined, what is accepted and what is
/// refused happen elsewhere, later, never here. What this layout owns
/// is the CONTEXT of that page: nothing more than the official kind it
/// is, and the word this shape calls its principal matter by — the
/// proof of identity itself.
///
/// It expresses. The product authenticates.
///
/// It knows no one who signs in, nothing that is typed, no secret, no
/// code, no provider, no session and no way anything is verified or
/// travels. It builds nothing either — the components own what stands
/// in every region — and it owns no order, no identity and no refusal:
/// the principal foundation owns them, once, for every shape built
/// around one matter.
///
/// The proof of identity is the only region such a page cannot do
/// without, and the compiler says so: it is not optional.
final class MentoraAuthenticationLayout extends MentoraPrincipalLayout {
  const MentoraAuthenticationLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required MentoraLayoutZone credentials,
    super.header,
    super.introduction,
    super.supportingContent,
    super.actions,
    super.footer,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  }) : super(principal: credentials);

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.authentication;

  /// The proof of identity — the word this shape calls its principal
  /// matter by. It is an alias, never a second field.
  MentoraLayoutZone get credentials => principal;
}
