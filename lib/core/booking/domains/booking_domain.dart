import '../models/booking.dart';
import '../models/booking_result.dart';
import '../models/booking_status.dart';
import '../repositories/booking_repository.dart';
import '../services/booking_validator.dart';

class BookingDomain {
  final BookingRepository repository;
  final BookingValidator validator;

  const BookingDomain({
    required this.repository,
    this.validator = const BookingValidator(),
  });

  Future<BookingResult> create(Booking booking) async {
    final existingBookings = await repository.findByExpert(booking.expertId);

    final canCreate = validator.canCreate(
      booking: booking,
      existingBookings: existingBookings,
    );

    if (!canCreate) {
      return BookingResult(
        success: false,
        message: 'Booking time conflict or invalid time range',
        booking: booking,
      );
    }

    return repository.create(booking);
  }

  Future<Booking?> findById(String bookingId) {
    return repository.findById(bookingId);
  }

  Future<BookingResult> confirm(Booking booking) {
    final confirmed = Booking(
      id: booking.id,
      consultationId: booking.consultationId,
      expertId: booking.expertId,
      clientId: booking.clientId,
      startTimeUtc: booking.startTimeUtc,
      endTimeUtc: booking.endTimeUtc,
      clientTimezone: booking.clientTimezone,
      expertTimezone: booking.expertTimezone,
      status: BookingStatus.confirmed,
    );

    return repository.update(confirmed);
  }

  Future<BookingResult> cancel(Booking booking) {
    final cancelled = Booking(
      id: booking.id,
      consultationId: booking.consultationId,
      expertId: booking.expertId,
      clientId: booking.clientId,
      startTimeUtc: booking.startTimeUtc,
      endTimeUtc: booking.endTimeUtc,
      clientTimezone: booking.clientTimezone,
      expertTimezone: booking.expertTimezone,
      status: BookingStatus.cancelled,
    );

    return repository.update(cancelled);
  }
}
