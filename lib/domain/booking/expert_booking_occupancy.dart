/// A read-only Booking fact identifying one occupied Expert slot.
///
/// Wave 2C deliberately preserves the legacy `bookingDate|bookingTime`
/// identity without interpreting weekdays, timezones, ranges, or durations.
final class ExpertBookingOccupancy {
  factory ExpertBookingOccupancy({
    required String bookingDate,
    required String bookingTime,
  }) {
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
    return ExpertBookingOccupancy._(
      bookingDate: bookingDate,
      bookingTime: bookingTime,
    );
  }

  const ExpertBookingOccupancy._({
    required this.bookingDate,
    required this.bookingTime,
  });

  final String bookingDate;
  final String bookingTime;

  String get slotIdentity => '$bookingDate|$bookingTime';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ExpertBookingOccupancy &&
            other.bookingDate == bookingDate &&
            other.bookingTime == bookingTime;
  }

  @override
  int get hashCode => Object.hash(bookingDate, bookingTime);
}
