import 'booking.dart';

class BookingResult {
  final bool success;
  final String? message;
  final Booking? booking;

  const BookingResult({required this.success, this.message, this.booking});
}
