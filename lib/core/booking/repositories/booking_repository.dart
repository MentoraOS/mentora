import '../models/booking.dart';
import '../models/booking_result.dart';

abstract class BookingRepository {
  Future<BookingResult> create(Booking booking);

  Future<Booking?> findById(String bookingId);

  Future<List<Booking>> findByExpert(String expertId);

  Future<List<Booking>> findByClient(String clientId);

  Future<BookingResult> update(Booking booking);

  Future<void> delete(String bookingId);
}
