import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/booking/booking_creation.dart';
import 'package:mentora/infrastructure/booking/booking_creation_firestore_mapper.dart';

void main() {
  group('BookingCreationFirestoreMapper', () {
    const mapper = BookingCreationFirestoreMapper();

    test('creates only the authorized exact Genesis payload plus expertId', () {
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
        ),
      );

      expect(data.keys.toSet(), {
        'clientId',
        'expertId',
        'expertName',
        'bookingDate',
        'bookingTime',
        'duration',
        'amount',
        'paymentStatus',
        'status',
        'agoraChannel',
        'clientNeed',
        'aiSummary',
        'createdAt',
      });
      expect(data['expertId'], 'expert_1');
      expect(data['status'], 'pending_payment');
      expect(data['paymentStatus'], 'pending');
      expect(data['amount'], 15000);
      expect(data['duration'], 30);
      expect(data['createdAt'], isA<FieldValue>());
      expect(data, isNot(contains('ledger')));
      expect(data, isNot(contains('escrow')));
    });
  });
}
