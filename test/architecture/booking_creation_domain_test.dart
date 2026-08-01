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

  group('BookingCreation — AD-022 C3 canonical occurrence snapshot', () {
    test('retains the accepted occurrence exactly', () {
      final booking = _booking();

      expect(booking.startUtc, DateTime.utc(2026, 8, 3, 9, 0));
      expect(booking.endUtc, DateTime.utc(2026, 8, 3, 10, 0));
      expect(booking.expertTimezone, 'Africa/Bamako');
    });

    test('preserves the named identity, never an offset substitute', () {
      // Identity and offset are distinct concepts: Africa/Bamako must not
      // collapse to UTC even while their offsets coincide.
      final booking = _booking();

      expect(booking.expertTimezone, isNot('UTC'));
      expect(booking.expertTimezone, isNot('+00:00'));
    });

    test('rejects non-UTC boundaries', () {
      expect(
        () => _bookingWith(startUtc: DateTime(2026, 8, 3, 9, 0)),
        throwsArgumentError,
      );
      expect(
        () => _bookingWith(endUtc: DateTime(2026, 8, 3, 10, 0)),
        throwsArgumentError,
      );
    });

    test('rejects an end at or before the start', () {
      expect(
        () => _bookingWith(endUtc: DateTime.utc(2026, 8, 3, 9, 0)),
        throwsArgumentError,
      );
      expect(
        () => _bookingWith(endUtc: DateTime.utc(2026, 8, 3, 8, 0)),
        throwsArgumentError,
      );
    });

    test('rejects boundaries inconsistent with the offer duration', () {
      // endUtc − startUtc must equal the snapshotted offer duration exactly
      // (AD-022 decision 3); no buffer is part of the reservation.
      expect(
        () => _bookingWith(endUtc: DateTime.utc(2026, 8, 3, 10, 15)),
        throwsArgumentError,
      );
      expect(
        () => _bookingWith(endUtc: DateTime.utc(2026, 8, 3, 9, 30)),
        throwsArgumentError,
      );
    });

    test('rejects a blank timezone identity', () {
      expect(
        () => _booking(<String, String>{'expertTimezone': '  '}),
        throwsArgumentError,
      );
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
  DateTime? startUtc,
  DateTime? endUtc,
}) {
  final start = startUtc ?? DateTime.utc(2026, 8, 3, 9, 0);
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
    startUtc: start,
    endUtc: endUtc ?? start.add(Duration(minutes: durationMinutes)),
    expertTimezone: override['expertTimezone'] ?? 'Africa/Bamako',
  );
}
