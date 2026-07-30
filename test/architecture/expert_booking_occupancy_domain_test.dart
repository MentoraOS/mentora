import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/booking/expert_booking_occupancy.dart';

void main() {
  group('ExpertBookingOccupancy', () {
    test('is immutable and has value semantics', () {
      final first = ExpertBookingOccupancy(
        bookingDate: 'Lundi',
        bookingTime: '09:00',
      );
      final same = ExpertBookingOccupancy(
        bookingDate: 'Lundi',
        bookingTime: '09:00',
      );

      expect(first, same);
      expect(first.hashCode, same.hashCode);
      expect(first.slotIdentity, 'Lundi|09:00');
    });

    test('rejects an empty date or time without normalizing valid values', () {
      expect(
        () => ExpertBookingOccupancy(bookingDate: '', bookingTime: '09:00'),
        throwsArgumentError,
      );
      expect(
        () => ExpertBookingOccupancy(bookingDate: 'Lundi', bookingTime: '   '),
        throwsArgumentError,
      );

      final occupancy = ExpertBookingOccupancy(
        bookingDate: ' Lundi ',
        bookingTime: ' 09:00 ',
      );
      expect(occupancy.slotIdentity, ' Lundi | 09:00 ');
    });
  });
}
