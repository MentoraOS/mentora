/// The official summary of one consultation.
///
/// One reservation owns exactly one summary, identified by the booking id
/// itself (summaryId == bookingId). The text is produced exclusively
/// through the governed chain memory -> summary service -> AI gateway ->
/// engine adapter; it is null until a generation succeeded.
final class ConsultationSummary {
  /// Also the summary identity: summaryId == bookingId.
  final String bookingId;

  final SummaryStatus status;

  /// The generated summary, verbatim; null until AVAILABLE.
  final String? summaryText;

  /// The engine kind that produced the text; null until AVAILABLE.
  final String? provider;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ConsultationSummary({
    required this.bookingId,
    required this.status,
    required this.summaryText,
    this.provider,
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
