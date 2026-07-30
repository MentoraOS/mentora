import '../domains/booking_domain.dart';
import '../models/booking.dart';
import '../models/booking_result.dart';

class BookingEngine {
  final BookingDomain domain;

  const BookingEngine({required this.domain});

  Future<BookingResult> create(Booking booking) {
    return domain.create(booking);
  }

  Future<BookingResult> confirm(Booking booking) {
    return domain.confirm(booking);
  }

  Future<BookingResult> cancel(Booking booking) {
    return domain.cancel(booking);
  }

  Future<Booking?> findById(String bookingId) {
    return domain.findById(bookingId);
  }
}
