import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';
import '../foundation/mentora_revealed_layout.dart';

/// The official Wizard Layout — the form of a work cut into several
/// steps.
///
/// It is not a stepper, not a workflow, not a process, not a beginning
/// and not a purchase. It is a WORK the application already cut into
/// steps, and the announcement of the step a person is on right now.
///
/// It expresses. It never decides.
///
/// A step is an IDENTITY — never a number, never a rank, never a
/// position in a list. Nothing here holds a current step, a next one or
/// a previous one, because nothing here chooses one: the application
/// announces which step is revealed, and announcing a different one is
/// what moves the work along. The acts a person presses belong to
/// MentoraButton, which reports what was asked; the answer to that
/// request belongs to the application. So this shape reports intentions
/// through the components that own them, and takes no decision itself —
/// there is no second owner of that report.
///
/// It knows no progression: no total, no remaining, no completed, no
/// ratio, no percentage. A work that counts its steps has already
/// decided something about them.
///
/// It validates nothing, holds no data, no network and no state of the
/// work. A step that is not revealed is NOT BUILT: it is absent from
/// the tree, from the focus and from what a screen reader announces —
/// nothing is hidden, because nothing is there.
///
/// It builds nothing at all, and it owns no identity, no refusal and no
/// surface: the revealing foundation owns them, once. What this shape
/// declares is its official kind, and the words a work uses for what it
/// holds — aliases over the one holder, never second fields.
final class MentoraWizardLayout extends MentoraRevealedLayout {
  const MentoraWizardLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required String wizardId,
    required String wizardSemanticLabel,
    required List<MentoraIdentifiedContent> steps,
    required String revealedStepId,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  }) : super(
         contextId: wizardId,
         contextSemanticLabel: wizardSemanticLabel,
         contents: steps,
         revealedContentId: revealedStepId,
       );

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.wizard;

  /// What this work IS — stable forever, never a rank.
  String get wizardId => contextId;

  /// What the screen reader hears about the work itself.
  String get wizardSemanticLabel => contextSemanticLabel;

  /// The steps the work was cut into, already built.
  List<MentoraIdentifiedContent> get steps => contents;

  /// Which step is revealed right now — announced, never chosen.
  String get revealedStepId => revealedContentId;
}
