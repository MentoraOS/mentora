import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/booking/booking_creation.dart';

void main() {
  group('BookingCreation', () {
    test('is immutable and has complete value semantics', () {
      final first = _booking();
      final same = _booking();

      expect(first, same);
      expect(first.hashCode, same.hashCode);
      expect(first.slotIdentity, 'expert_1| Lundi | 09:00 ');
    });

    test('preserves exact legacy strings and constants', () {
      final booking = _booking();

      expect(booking.bookingDate, ' Lundi ');
      expect(booking.bookingTime, ' 09:00 ');
      expect(BookingCreation.initialStatus, 'pending_payment');
      expect(BookingCreation.paymentStatus, 'pending');
      expect(BookingCreation.amount, 15000);
      expect(BookingCreation.durationMinutes, 30);
    });

    test('rejects blank required identity and slot values', () {
      for (final override in <Map<String, String>>[
        {'clientId': ' '},
        {'expertId': ''},
        {'expertName': ' '},
        {'bookingDate': ''},
        {'bookingTime': ' '},
        {'agoraChannel': ''},
      ]) {
        expect(() => _booking(override), throwsArgumentError);
      }
    });
  });
}

BookingCreation _booking([Map<String, String> override = const {}]) {
  return BookingCreation(
    clientId: override['clientId'] ?? 'client_1',
    expertId: override['expertId'] ?? 'expert_1',
    expertName: override['expertName'] ?? 'Expert',
    bookingDate: override['bookingDate'] ?? ' Lundi ',
    bookingTime: override['bookingTime'] ?? ' 09:00 ',
    agoraChannel: override['agoraChannel'] ?? 'mentora_test',
    clientNeed: 'Need',
    aiSummary: 'Summary',
  );
}
