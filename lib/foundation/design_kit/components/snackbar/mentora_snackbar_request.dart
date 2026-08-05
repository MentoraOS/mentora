import 'mentora_snackbar_style.dart';

/// A demand addressed to the message service — one message, one idea.
///
/// It carries no act: a message never asks. What must be decided is a
/// [MentoraDialog]; what must survive the screen is a notification.
final class MentoraSnackbarRequest {
  final MentoraSnackbarVariant variant;

  /// The single sentence. The application owns every string
  /// (Localization Engine); the Kit composes none.
  final String message;

  /// The screen reader's wording, when it must differ from the one on
  /// screen.
  final String? semanticLabel;

  const MentoraSnackbarRequest({
    required this.variant,
    required this.message,
    this.semanticLabel,
  });

  /// The contracts a demand must honor — verified once, at the door of
  /// the service, never silently repaired.
  void verify() {
    if (message.isEmpty) {
      throw StateError('A message without words says nothing.');
    }
    if (message.contains('\n')) {
      throw StateError(
        'One message, one idea: a transient signal never tells a '
        'story.',
      );
    }
  }

  /// How long this message stays — null when it reports a state that
  /// is still happening.
  Duration? get dwell => dwellOf(variant);

  bool get reportsOngoing => reportsOngoingState(variant);
}

/// How a message ended.
enum MentoraSnackbarOutcome {
  /// It disappeared on its own, its time served.
  expired,

  /// It was ended — by the person, or by the application.
  dismissed,

  /// Another message took its place.
  replaced,

  /// Everything pending was cleared at once.
  cleared,
}

/// What the caller receives when the message leaves.
final class MentoraSnackbarResult {
  final MentoraSnackbarOutcome outcome;

  const MentoraSnackbarResult.expired()
    : outcome = MentoraSnackbarOutcome.expired;

  const MentoraSnackbarResult.dismissed()
    : outcome = MentoraSnackbarOutcome.dismissed;

  const MentoraSnackbarResult.replaced()
    : outcome = MentoraSnackbarOutcome.replaced;

  const MentoraSnackbarResult.cleared()
    : outcome = MentoraSnackbarOutcome.cleared;

  @override
  bool operator ==(Object other) =>
      other is MentoraSnackbarResult && other.outcome == outcome;

  @override
  int get hashCode => outcome.hashCode;
}
