import 'mentora_dialog_style.dart';

/// What an action means in the exchange. A recommendation is a help,
/// never a pressure; a danger stays explicit, never disguised.
enum MentoraDialogActionIntent { neutral, recommended, dangerous }

/// One act offered by a dialog. The application owns every string
/// (Localization Engine); the Kit composes none.
final class MentoraDialogAction {
  final String id;
  final String label;
  final MentoraDialogActionIntent intent;

  const MentoraDialogAction({
    required this.id,
    required this.label,
    this.intent = MentoraDialogActionIntent.neutral,
  });

  bool get isDangerous => intent == MentoraDialogActionIntent.dangerous;

  bool get isRecommended => intent == MentoraDialogActionIntent.recommended;
}

/// A demand addressed to the dialog service — what to say, what to
/// offer, and what it will cost. It carries no business, no decision
/// and no rule: only the exchange to hold.
final class MentoraDialogRequest {
  final MentoraDialogVariant variant;
  final String title;
  final String message;

  /// What happens if the act is performed. A critical dialog is
  /// refused without it: a consequence is never hidden.
  final String? consequence;

  final List<MentoraDialogAction> actions;

  /// The screen reader's name for the layer, when it must differ from
  /// the title.
  final String? semanticLabel;

  const MentoraDialogRequest({
    required this.variant,
    required this.title,
    required this.message,
    this.consequence,
    this.actions = const [],
    this.semanticLabel,
  });

  /// The contracts a request must honor — verified once, at the door
  /// of the service, never silently repaired.
  void verify() {
    if (title.isEmpty || message.isEmpty) {
      throw StateError('A dialog without a title or a message says nothing.');
    }
    if (variant == MentoraDialogVariant.critical && consequence == null) {
      throw StateError(
        'A critical dialog states its consequence: a consequence is '
        'never hidden.',
      );
    }
    if (_demandsAnAnswer && actions.length < 2) {
      throw StateError(
        'A dialog that asks offers at least two ways out: a person is '
        'never forced into a single path.',
      );
    }
    if (actions.where((action) => action.isRecommended).length > 1) {
      throw StateError(
        'One recommendation at most: two recommendations recommend '
        'nothing.',
      );
    }
    final ids = actions.map((action) => action.id).toSet();
    if (ids.length != actions.length) {
      throw StateError('Two acts never share one identity.');
    }
    if (actions.any((action) => action.label.isEmpty)) {
      throw StateError('An act without a name is never offered.');
    }
  }

  bool get _demandsAnAnswer =>
      variant == MentoraDialogVariant.confirmation ||
      variant == MentoraDialogVariant.decision ||
      variant == MentoraDialogVariant.critical;

  /// The act Enter performs — a recommendation, and never a danger:
  /// a dangerous act is always chosen deliberately.
  MentoraDialogAction? get keyboardDefault {
    for (final action in actions) {
      if (action.isRecommended && !action.isDangerous) return action;
    }
    return null;
  }
}

/// How an exchange ended.
enum MentoraDialogOutcome {
  /// The person chose one of the offered acts.
  answered,

  /// The person stepped back — the layer allowed it.
  dismissed,

  /// The application closed the layer itself.
  closed,

  /// Another demand took the layer's place.
  replaced,
}

/// What the caller receives when the exchange ends. `actionId` is
/// present exactly when the outcome is [MentoraDialogOutcome.answered].
final class MentoraDialogResult {
  final MentoraDialogOutcome outcome;
  final String? actionId;

  const MentoraDialogResult.answered(String this.actionId)
    : outcome = MentoraDialogOutcome.answered;

  const MentoraDialogResult.dismissed()
    : outcome = MentoraDialogOutcome.dismissed,
      actionId = null;

  const MentoraDialogResult.closed()
    : outcome = MentoraDialogOutcome.closed,
      actionId = null;

  const MentoraDialogResult.replaced()
    : outcome = MentoraDialogOutcome.replaced,
      actionId = null;

  bool get isAnswer => outcome == MentoraDialogOutcome.answered;

  @override
  bool operator ==(Object other) =>
      other is MentoraDialogResult &&
      other.outcome == outcome &&
      other.actionId == actionId;

  @override
  int get hashCode => Object.hash(outcome, actionId);
}
