import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/booking/domains/booking_domain.dart';
import 'package:mentora/core/booking/engine/booking_engine.dart';
import 'package:mentora/core/booking/models/booking.dart';
import 'package:mentora/core/booking/models/booking_status.dart';
import 'package:mentora/core/booking/repositories/memory_booking_repository.dart';

import 'package:mentora/core/consultation/domains/consultation_domain.dart';
import 'package:mentora/core/consultation/engine/consultation_engine.dart';
import 'package:mentora/core/consultation/models/consultation.dart';
import 'package:mentora/core/consultation/models/consultation_status.dart';
import 'package:mentora/core/consultation/models/consultation_type.dart';
import 'package:mentora/core/consultation/repositories/memory_consultation_repository.dart';

import 'package:mentora/core/scheduling/engine/availability_engine.dart';
import 'package:mentora/core/scheduling/engine/scheduling_engine.dart';
import 'package:mentora/core/scheduling/engine/timezone_engine.dart';

void main() {
  group('Scheduling Engine', () {
    test('should create consultation and confirm booking', () async {
      final bookingRepository = MemoryBookingRepository();
      final consultationRepository = MemoryConsultationRepository();

      final bookingEngine = BookingEngine(
        domain: BookingDomain(repository: bookingRepository),
      );

      final consultationEngine = ConsultationEngine(
        domain: ConsultationDomain(repository: consultationRepository),
      );

      final schedulingEngine = SchedulingEngine(
        availabilityEngine: AvailabilityEngine.instance,
        bookingEngine: bookingEngine,
        consultationEngine: consultationEngine,
        timezoneEngine: TimezoneEngine.instance,
      );

      final booking = Booking(
        id: 'booking_scheduling_001',
        consultationId: 'consultation_scheduling_001',
        expertId: 'expert_001',
        clientId: 'client_001',
        startTimeUtc: DateTime.utc(2026, 7, 8, 10),
        endTimeUtc: DateTime.utc(2026, 7, 8, 10, 30),
        clientTimezone: 'Africa/Bamako',
        expertTimezone: 'Asia/Tokyo',
        status: BookingStatus.pending,
      );

      final consultation = Consultation(
        id: 'consultation_scheduling_001',
        expertId: 'expert_001',
        clientId: 'client_001',
        scheduledAt: DateTime.utc(2026, 7, 8, 10),
        duration: const Duration(minutes: 30),
        status: ConsultationStatus.draft,
        type: ConsultationType.scheduled,
      );

      final result = await schedulingEngine.scheduleConsultation(
        booking: booking,
        consultation: consultation,
      );

      expect(result.success, isTrue);
      expect(result.booking?.status, BookingStatus.confirmed);
      expect(result.booking?.consultationId, 'consultation_scheduling_001');
    });
  });
}
