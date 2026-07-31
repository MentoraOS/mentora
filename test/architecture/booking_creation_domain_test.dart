import 'dart:io';

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

    test('preserves exact legacy strings and lifecycle constants', () {
      final booking = _booking();

      expect(booking.bookingDate, ' Lundi ');
      expect(booking.bookingTime, ' 09:00 ');
      expect(BookingCreation.initialStatus, 'pending_payment');
      expect(BookingCreation.paymentStatus, 'pending');
    });

    test('carries the commercial snapshot supplied by the caller', () {
      final booking = _booking();

      expect(booking.offerId, 'expert:expert_1:consultation:60m');
      expect(booking.durationMinutes, 60);
      expect(booking.amountMinor, 50000);
      expect(booking.currency, 'XOF');
    });

    test('exposes no hardcoded consultation amount or duration default', () {
      // AD-021 decision 11: the legacy 15,000 / 30-minute defaults are gone.
      final source = File(
        'lib/domain/booking/booking_creation.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('15000')));
      expect(source, isNot(contains('50000')));
      expect(source, isNot(contains('durationMinutes = 30')));
    });

    test('rejects blank required identity and slot values', () {
      for (final override in <Map<String, String>>[
        {'clientId': ' '},
        {'expertId': ''},
        {'expertName': ' '},
        {'bookingDate': ''},
        {'bookingTime': ' '},
        {'agoraChannel': ''},
        {'offerId': ' '},
        {'currency': ''},
      ]) {
        expect(() => _booking(override), throwsArgumentError);
      }
    });

    test('rejects a non-positive duration and a negative amount', () {
      expect(() => _bookingWith(durationMinutes: 0), throwsArgumentError);
      expect(() => _bookingWith(durationMinutes: -30), throwsArgumentError);
      expect(() => _bookingWith(amountMinor: -1), throwsArgumentError);
    });
  });
}

BookingCreation _booking([Map<String, String> override = const {}]) {
  return _bookingWith(override: override);
}

BookingCreation _bookingWith({
  Map<String, String> override = const {},
  int durationMinutes = 60,
  int amountMinor = 50000,
}) {
  return BookingCreation(
    clientId: override['clientId'] ?? 'client_1',
    expertId: override['expertId'] ?? 'expert_1',
    expertName: override['expertName'] ?? 'Expert',
    bookingDate: override['bookingDate'] ?? ' Lundi ',
    bookingTime: override['bookingTime'] ?? ' 09:00 ',
    agoraChannel: override['agoraChannel'] ?? 'mentora_test',
    clientNeed: 'Need',
    aiSummary: 'Summary',
    offerId: override['offerId'] ?? 'expert:expert_1:consultation:60m',
    durationMinutes: durationMinutes,
    amountMinor: amountMinor,
    currency: override['currency'] ?? 'XOF',
  );
}
