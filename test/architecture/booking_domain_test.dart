import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/booking/domains/booking_domain.dart';
import 'package:mentora/core/booking/models/booking.dart';
import 'package:mentora/core/booking/models/booking_status.dart';
import 'package:mentora/core/booking/repositories/memory_booking_repository.dart';

void main() {
  group('Booking Domain', () {
    test('should create booking successfully', () async {
      final repository = MemoryBookingRepository();

      final domain = BookingDomain(repository: repository);

      final booking = Booking(
        id: 'booking_001',
        consultationId: 'consultation_001',
        expertId: 'expert_001',
        clientId: 'client_001',
        startTimeUtc: DateTime.utc(2026, 7, 7, 10),
        endTimeUtc: DateTime.utc(2026, 7, 7, 10, 30),
        clientTimezone: 'Africa/Bamako',
        expertTimezone: 'Asia/Tokyo',
      );

      final result = await domain.create(booking);

      expect(result.success, isTrue);
      expect(result.booking?.id, 'booking_001');
    });

    test('should reject overlapping booking for same expert', () async {
      final repository = MemoryBookingRepository();

      final domain = BookingDomain(repository: repository);

      final firstBooking = Booking(
        id: 'booking_001',
        consultationId: 'consultation_001',
        expertId: 'expert_001',
        clientId: 'client_001',
        startTimeUtc: DateTime.utc(2026, 7, 7, 10),
        endTimeUtc: DateTime.utc(2026, 7, 7, 10, 30),
        clientTimezone: 'Africa/Bamako',
        expertTimezone: 'Asia/Tokyo',
      );

      final secondBooking = Booking(
        id: 'booking_002',
        consultationId: 'consultation_002',
        expertId: 'expert_001',
        clientId: 'client_002',
        startTimeUtc: DateTime.utc(2026, 7, 7, 10, 15),
        endTimeUtc: DateTime.utc(2026, 7, 7, 10, 45),
        clientTimezone: 'Africa/Bamako',
        expertTimezone: 'Asia/Tokyo',
      );

      await domain.create(firstBooking);

      final result = await domain.create(secondBooking);

      expect(result.success, isFalse);
    });

    test('should confirm booking', () async {
      final repository = MemoryBookingRepository();

      final domain = BookingDomain(repository: repository);

      final booking = Booking(
        id: 'booking_003',
        consultationId: 'consultation_003',
        expertId: 'expert_002',
        clientId: 'client_001',
        startTimeUtc: DateTime.utc(2026, 7, 7, 11),
        endTimeUtc: DateTime.utc(2026, 7, 7, 11, 30),
        clientTimezone: 'Africa/Bamako',
        expertTimezone: 'Asia/Tokyo',
      );

      await domain.create(booking);

      final result = await domain.confirm(booking);

      expect(result.success, isTrue);
      expect(result.booking?.status, BookingStatus.confirmed);
    });
  });
}
