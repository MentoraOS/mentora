import '../models/booking.dart';

class BookingValidator {
  const BookingValidator();

  bool hasTimeConflict({
    required Booking booking,
    required List<Booking> existingBookings,
  }) {
    return existingBookings.any((existing) {
      final sameExpert = existing.expertId == booking.expertId;
      final notCancelled = !existing.isCancelled;

      final overlaps =
          booking.startTimeUtc.isBefore(existing.endTimeUtc) &&
          booking.endTimeUtc.isAfter(existing.startTimeUtc);

      return sameExpert && notCancelled && overlaps;
    });
  }

  bool isValidTimeRange(Booking booking) {
    return booking.endTimeUtc.isAfter(booking.startTimeUtc);
  }

  bool canCreate({
    required Booking booking,
    required List<Booking> existingBookings,
  }) {
    if (!isValidTimeRange(booking)) {
      return false;
    }

    if (hasTimeConflict(booking: booking, existingBookings: existingBookings)) {
      return false;
    }

    return true;
  }
}
