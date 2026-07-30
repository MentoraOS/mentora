import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/infrastructure/booking/expert_booking_occupancy_firestore_mapper.dart';

void main() {
  group('ExpertBookingOccupancyFirestoreMapper', () {
    const mapper = ExpertBookingOccupancyFirestoreMapper();

    test('maps the current bookingDate and bookingTime representation', () {
      final occupancy = mapper.fromMap(const {
        'bookingDate': 'Lundi',
        'bookingTime': '09:00',
      });

      expect(occupancy.bookingDate, 'Lundi');
      expect(occupancy.bookingTime, '09:00');
      expect(occupancy.slotIdentity, 'Lundi|09:00');
    });

    test('rejects missing required fields', () {
      expect(
        () => mapper.fromMap(const {'bookingDate': 'Lundi'}),
        throwsFormatException,
      );
      expect(
        () => mapper.fromMap(const {'bookingTime': '09:00'}),
        throwsFormatException,
      );
    });

    test('rejects invalid types and empty persisted values', () {
      expect(
        () => mapper.fromMap(const {'bookingDate': 1, 'bookingTime': '09:00'}),
        throwsFormatException,
      );
      expect(
        () => mapper.fromMap(const {'bookingDate': 'Lundi', 'bookingTime': ''}),
        throwsFormatException,
      );
    });
  });
}
