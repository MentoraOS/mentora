import 'consultation_summary.dart';

/// Port for summary STATE persistence — metadata only, never content.
abstract interface class SummaryRepository {
  /// Persists the reservation's summary status (summaryId == bookingId).
  ///
  /// The reservation must exist and [userId] must be its client or expert
  /// — anything else throws [SummaryStateNotFoundException].
  Future<void> saveStatus({
    required String bookingId,
    required String userId,
    required SummaryStatus status,
  });

  /// The persisted summary state, or null when none was ever recorded.
  /// Same guards as [saveStatus].
  Future<ConsultationSummary?> findByBookingId({
    required String bookingId,
    required String userId,
  });
}

final class SummaryStateNotFoundException implements Exception {
  const SummaryStateNotFoundException();
}

final class SummaryStateRepositoryException implements Exception {
  const SummaryStateRepositoryException({required this.cause});

  final Object cause;
}
