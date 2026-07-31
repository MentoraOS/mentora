import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mentora/domain/booking/booking_creation.dart';
import 'package:mentora/domain/booking/booking_creation_repository.dart';
import 'package:mentora/infrastructure/booking/firestore_booking_creation_repository.dart';

const _projectId = 'mentora-7e926';
final _expectedEmulatorHost = Platform.isAndroid
    ? '10.0.2.2:8080'
    : '127.0.0.1:8080';
const _configuredEmulatorHost = String.fromEnvironment(
  'FIRESTORE_EMULATOR_HOST',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'atomically creates one initial Booking against Firestore Emulator',
    (tester) async {
      if (_configuredEmulatorHost != _expectedEmulatorHost) {
        fail(
          'Refusing production access: FIRESTORE_EMULATOR_HOST must be '
          '$_expectedEmulatorHost, got '
          '${_configuredEmulatorHost.isEmpty ? "<absent>" : _configuredEmulatorHost}.',
        );
      }

      final marker = DateTime.now().microsecondsSinceEpoch.toString();
      final app = await Firebase.initializeApp(
        name: 'booking-creation-emulator-$marker',
        options: const FirebaseOptions(
          apiKey: 'emulator-only',
          appId: '1:1:android:emulator',
          messagingSenderId: '1',
          projectId: _projectId,
        ),
      );
      expect(app.options.projectId, _projectId);
      expect(app.options.apiKey, 'emulator-only');

      final firestore = FirebaseFirestore.instanceFor(app: app);
      final hostAndPort = _expectedEmulatorHost.split(':');
      firestore.useFirestoreEmulator(
        hostAndPort.first,
        int.parse(hostAndPort.last),
      );

      final expertId = 'arch008_expert_$marker';
      final bookingDate = 'ARCH008-$marker';
      const bookingTime = '09:00';
      final bookings = firestore.collection('bookings');
      final unrelated = bookings.doc('arch008_unrelated_$marker');
      final expert = firestore.collection('experts').doc(expertId);
      final protectedCollections = <String>[
        'payments',
        'ledger_transactions',
        'escrows',
      ];

      Future<int> collectionSize(String collection) async =>
          (await firestore.collection(collection).get()).docs.length;

      final protectedCounts = <String, int>{
        for (final collection in protectedCollections)
          collection: await collectionSize(collection),
      };

      await unrelated.set(<String, dynamic>{
        'expertId': 'unrelated_expert',
        'bookingDate': bookingDate,
        'bookingTime': bookingTime,
        'status': 'sentinel',
      });
      await expert.set(<String, dynamic>{
        'availability': <String, List<String>>{
          'Lundi': <String>['09:00'],
        },
        'sentinel': 'must-survive',
      });

      final repositoryA = FirestoreBookingCreationRepository(
        firestore: firestore,
      );
      final repositoryB = FirestoreBookingCreationRepository(
        firestore: firestore,
      );
      final bookingA = _booking(
        clientId: 'client_a',
        expertId: expertId,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
      );
      final bookingB = _booking(
        clientId: 'client_b',
        expertId: expertId,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
      );

      try {
        final outcomes = await Future.wait<Object>([
          repositoryA
              .create(bookingA)
              .then<Object>((id) => id)
              .catchError((Object error) => error),
          repositoryB
              .create(bookingB)
              .then<Object>((id) => id)
              .catchError((Object error) => error),
        ]);

        final successes = outcomes.whereType<String>().toList();
        final conflicts = outcomes
            .whereType<BookingCreationConflictException>()
            .toList();
        expect(successes, hasLength(1));
        expect(conflicts, hasLength(1));

        final created = await bookings
            .where('expertId', isEqualTo: expertId)
            .where('bookingDate', isEqualTo: bookingDate)
            .where('bookingTime', isEqualTo: bookingTime)
            .get();
        expect(created.docs, hasLength(1));
        expect(created.docs.single.id, successes.single);

        final data = created.docs.single.data();
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
          'createdAt',
        });
        expect(data['expertId'], expertId);
        expect(data['status'], 'pending_payment');
        expect(data['paymentStatus'], 'pending');
        // AD-021: the commercial snapshot is persisted through the existing
        // transaction, exactly as supplied by the selected offer.
        expect(data['offerId'], 'expert:$expertId:consultation:120m');
        expect(data['amount'], 100000);
        expect(data['duration'], 120);
        expect(data['currency'], 'XOF');
        expect(data['createdAt'], isA<Timestamp>());

        final unrelatedAfter = await unrelated.get(
          const GetOptions(source: Source.server),
        );
        expect(unrelatedAfter.data()?['status'], 'sentinel');

        final expertAfter = await expert.get(
          const GetOptions(source: Source.server),
        );
        expect(expertAfter.data()?['availability'], {
          'Lundi': ['09:00'],
        });
        expect(expertAfter.data()?['sentinel'], 'must-survive');

        for (final collection in protectedCollections) {
          expect(
            await collectionSize(collection),
            protectedCounts[collection],
            reason: '$collection must not be mutated by ARCH-008',
          );
        }
      } finally {
        final created = await bookings
            .where('expertId', isEqualTo: expertId)
            .get();
        for (final document in created.docs) {
          await document.reference.delete();
        }
        final guards = await firestore
            .collection('_booking_creation_slots')
            .where('expertId', isEqualTo: expertId)
            .get();
        for (final document in guards.docs) {
          await document.reference.delete();
        }
        await unrelated.delete();
        await expert.delete();
        await app.delete();
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

BookingCreation _booking({
  required String clientId,
  required String expertId,
  required String bookingDate,
  required String bookingTime,
}) {
  return BookingCreation(
    clientId: clientId,
    expertId: expertId,
    expertName: 'Expert ARCH-008',
    bookingDate: bookingDate,
    bookingTime: bookingTime,
    agoraChannel: 'mentora_arch008',
    clientNeed: 'Need',
    aiSummary: 'Summary',
    offerId: 'expert:$expertId:consultation:120m',
    durationMinutes: 120,
    amountMinor: 100000,
    currency: 'XOF',
  );
}
