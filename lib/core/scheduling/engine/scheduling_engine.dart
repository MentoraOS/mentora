import '../../booking/engine/booking_engine.dart';
import '../../booking/models/booking.dart';
import '../../booking/models/booking_result.dart';

import '../../consultation/engine/consultation_engine.dart';
import '../../consultation/models/consultation.dart';
import '../../consultation/models/consultation_result.dart';

import 'availability_engine.dart';
import 'timezone_engine.dart';

class SchedulingEngine {
  final AvailabilityEngine availabilityEngine;
  final BookingEngine bookingEngine;
  final ConsultationEngine consultationEngine;
  final TimezoneEngine timezoneEngine;

  const SchedulingEngine({
    required this.availabilityEngine,
    required this.bookingEngine,
    required this.consultationEngine,
    required this.timezoneEngine,
  });

  Future<BookingResult> scheduleConsultation({
    required Booking booking,
    required Consultation consultation,
  }) async {
    final bookingResult = await bookingEngine.create(booking);

    if (!bookingResult.success || bookingResult.booking == null) {
      return bookingResult;
    }

    final consultationResult = await consultationEngine.create(consultation);

    if (!consultationResult.success ||
        consultationResult.consultation == null) {
      return BookingResult(
        success: false,
        message: consultationResult.message ?? 'Consultation creation failed',
        booking: bookingResult.booking,
      );
    }

    return bookingEngine.confirm(bookingResult.booking!);
  }

  Future<BookingResult> createBooking(Booking booking) {
    return bookingEngine.create(booking);
  }

  Future<ConsultationResult> createConsultation(Consultation consultation) {
    return consultationEngine.create(consultation);
  }

  Future<BookingResult> confirmBooking(Booking booking) {
    return bookingEngine.confirm(booking);
  }
}
