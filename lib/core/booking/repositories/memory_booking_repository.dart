import '../models/booking.dart';
import '../models/booking_result.dart';
import 'booking_repository.dart';

class MemoryBookingRepository implements BookingRepository {
  final Map<String, Booking> _bookings = {};

  @override
  Future<BookingResult> create(Booking booking) async {
    _bookings[booking.id] = booking;

    return BookingResult(
      success: true,
      message: 'Booking created',
      booking: booking,
    );
  }

  @override
  Future<Booking?> findById(String bookingId) async {
    return _bookings[bookingId];
  }

  @override
  Future<List<Booking>> findByExpert(String expertId) async {
    return _bookings.values
        .where((booking) => booking.expertId == expertId)
        .toList();
  }

  @override
  Future<List<Booking>> findByClient(String clientId) async {
    return _bookings.values
        .where((booking) => booking.clientId == clientId)
        .toList();
  }

  @override
  Future<BookingResult> update(Booking booking) async {
    _bookings[booking.id] = booking;

    return BookingResult(
      success: true,
      message: 'Booking updated',
      booking: booking,
    );
  }

  @override
  Future<void> delete(String bookingId) async {
    _bookings.remove(bookingId);
  }
}
