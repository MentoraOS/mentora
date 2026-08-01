/// Read-only projection of one reservation for the Booking Dashboard.
///
/// This is a display projection of existing Booking facts — it owns no
/// lifecycle, no commercial truth and no temporal authority. Fields absent
/// from legacy documents stay null; [raw] carries the source document for
/// the existing detail/reschedule/payment navigation, which consumes the
/// same legacy map shape as before.
final class BookingOverview {
  final String bookingId;
  final String status;
  final String clientId;
  final String expertId;
  final String expertName;
  final String bookingDate;
  final String bookingTime;
  final int? durationMinutes;
  final int? amountMinor;
  final String? currency;
  final String? expertTimezone;
  final String aiSummary;
  final Map<String, dynamic> raw;

  const BookingOverview({
    required this.bookingId,
    required this.status,
    required this.clientId,
    required this.expertId,
    required this.expertName,
    required this.bookingDate,
    required this.bookingTime,
    required this.durationMinutes,
    required this.amountMinor,
    required this.currency,
    required this.expertTimezone,
    required this.aiSummary,
    required this.raw,
  });
}

/// Port streaming the reservations visible to one user.
///
/// The stream re-emits on every persisted change, which is what keeps the
/// dashboard current immediately after a payment, cancellation or reschedule.
abstract interface class BookingOverviewRepository {
  Stream<List<BookingOverview>> watchForClient(String clientId);

  Stream<List<BookingOverview>> watchForExpert(String expertId);
}

final class BookingOverviewRepositoryException implements Exception {
  const BookingOverviewRepositoryException({required this.cause});

  final Object cause;
}
