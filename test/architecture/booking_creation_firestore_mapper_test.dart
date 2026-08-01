import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/booking/booking_creation.dart';
import 'package:mentora/infrastructure/booking/booking_creation_firestore_mapper.dart';

void main() {
  group('BookingCreationFirestoreMapper', () {
    const mapper = BookingCreationFirestoreMapper();

    test('creates the authorized payload plus the commercial snapshot', () {
      final data = mapper.toMap(
        BookingCreation(
          clientId: 'client_1',
          expertId: 'expert_1',
          expertName: 'Expert',
          bookingDate: 'Lundi',
          bookingTime: '09:00',
          agoraChannel: 'mentora_1',
          clientNeed: 'Need',
          aiSummary: 'Summary',
          offerId: 'expert:expert_1:consultation:120m',
          durationMinutes: 120,
          amountMinor: 100000,
          currency: 'XOF',
          startUtc: DateTime.utc(2026, 8, 3, 9, 0),
          endUtc: DateTime.utc(2026, 8, 3, 11, 0),
          expertTimezone: 'Africa/Bamako',
        ),
      );

      expect(data.keys.toSet(), {
        'clientId',
        'expertId',
        'expertName',
        'bookingDate',
        'bookingTime',
        'offerId',
        'duration',
        'amount',
        'currency',
        'paymentStatus',
        'status',
        'agoraChannel',
        'clientNeed',
        'aiSummary',
        'startUtc',
        'endUtc',
        'expertTimezone',
        'createdAt',
      });
      expect(data['expertId'], 'expert_1');
      expect(data['status'], 'pending_payment');
      expect(data['paymentStatus'], 'pending');
      // AD-021: persisted commercial values come from the selected offer.
      expect(data['offerId'], 'expert:expert_1:consultation:120m');
      expect(data['amount'], 100000);
      expect(data['duration'], 120);
      expect(data['currency'], 'XOF');
      expect(data['createdAt'], isA<FieldValue>());
      // AD-022 C3: canonical occurrence snapshot persists as Timestamps and
      // the verbatim named timezone identity — a round trip through the
      // Timestamp representation restores the exact UTC instants.
      expect(data['startUtc'], isA<Timestamp>());
      expect(data['endUtc'], isA<Timestamp>());
      expect(
        (data['startUtc'] as Timestamp).toDate().toUtc(),
        DateTime.utc(2026, 8, 3, 9, 0),
      );
      expect(
        (data['endUtc'] as Timestamp).toDate().toUtc(),
        DateTime.utc(2026, 8, 3, 11, 0),
      );
      expect(data['expertTimezone'], 'Africa/Bamako');
      expect(data, isNot(contains('ledger')));
      expect(data, isNot(contains('escrow')));
    });
  });
}
