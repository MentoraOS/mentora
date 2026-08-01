/// Port for the Booking-owned reschedule transition.
///
/// Booking owns its lifecycle: rescheduling replaces the reservation's
/// occurrence with a newly revalidated and Scheduling-interpreted one while
/// keeping every other fact. The previous canonical boundaries are preserved
/// as history (`previousStartUtc`/`previousEndUtc`), never deleted. Refunds,
/// conflict exclusion and slot-guard release remain separate contracts.
abstract interface class BookingRescheduleRepository {
  /// Applies [update] to the client's reservation.
  ///
  /// Throws [BookingRescheduleNotFoundException] when no such booking exists
  /// for [clientId], [BookingRescheduleStateException] when the reservation
  /// is not reschedulable, and [BookingRescheduleConsistencyException] when
  /// the new occurrence does not match the reservation's snapshotted
  /// duration (AD-022 decision 3).
  Future<void> reschedule({
    required String bookingId,
    required String clientId,
    required BookingRescheduleUpdate update,
  });
}

/// The revalidated replacement occurrence, produced by Application through
/// the C2 revalidation and C3 interpretation path — never by Presentation.
final class BookingRescheduleUpdate {
  final DateTime startUtc;
  final DateTime endUtc;
  final String expertTimezone;
  final String bookingDate;
  final String bookingTime;

  factory BookingRescheduleUpdate({
    required DateTime startUtc,
    required DateTime endUtc,
    required String expertTimezone,
    required String bookingDate,
    required String bookingTime,
  }) {
    if (!startUtc.isUtc) {
      throw ArgumentError.value(startUtc, 'startUtc', 'must be a UTC instant');
    }
    if (!endUtc.isUtc) {
      throw ArgumentError.value(endUtc, 'endUtc', 'must be a UTC instant');
    }
    if (!endUtc.isAfter(startUtc)) {
      throw ArgumentError.value(endUtc, 'endUtc', 'must be after startUtc');
    }
    if (expertTimezone.trim().isEmpty) {
      throw ArgumentError.value(
        expertTimezone,
        'expertTimezone',
        'must not be empty',
      );
    }
    if (bookingDate.trim().isEmpty) {
      throw ArgumentError.value(
        bookingDate,
        'bookingDate',
        'must not be empty',
      );
    }
    if (bookingTime.trim().isEmpty) {
      throw ArgumentError.value(
        bookingTime,
        'bookingTime',
        'must not be empty',
      );
    }

    return BookingRescheduleUpdate._(
      startUtc: startUtc,
      endUtc: endUtc,
      expertTimezone: expertTimezone,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
    );
  }

  const BookingRescheduleUpdate._({
    required this.startUtc,
    required this.endUtc,
    required this.expertTimezone,
    required this.bookingDate,
    required this.bookingTime,
  });
}

final class BookingRescheduleNotFoundException implements Exception {
  const BookingRescheduleNotFoundException();
}

final class BookingRescheduleStateException implements Exception {
  const BookingRescheduleStateException({required this.currentStatus});

  final String currentStatus;
}

/// The new occurrence contradicts the reservation's persisted duration.
final class BookingRescheduleConsistencyException implements Exception {
  const BookingRescheduleConsistencyException();
}

final class BookingRescheduleRepositoryException implements Exception {
  const BookingRescheduleRepositoryException({required this.cause});

  final Object cause;
}
