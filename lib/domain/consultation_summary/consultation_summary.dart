/// The official summary of one consultation — METADATA ONLY today.
///
/// One reservation owns exactly one summary, identified by the booking id
/// itself (summaryId == bookingId). No generated text, no engine content
/// of any kind exists anywhere yet: this wave is the architecture that a
/// future wave fills by swapping the simulated provider for a real one
/// behind the AI gateway. Nothing else will change.
final class ConsultationSummary {
  /// Also the summary identity: summaryId == bookingId.
  final String bookingId;

  final SummaryStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ConsultationSummary({
    required this.bookingId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// The only summary lifecycle states. Nothing else.
enum SummaryStatus { notGenerated, generating, available, failed }

sealed class SummaryFailure implements Exception {
  const SummaryFailure();
}

final class SummaryUnauthenticatedFailure extends SummaryFailure {
  const SummaryUnauthenticatedFailure();
}

/// No reservation with this identity involves this user.
final class SummaryNotFoundFailure extends SummaryFailure {
  const SummaryNotFoundFailure();
}

final class SummaryUnavailableFailure extends SummaryFailure {
  const SummaryUnavailableFailure({required this.cause});

  final Object cause;
}
