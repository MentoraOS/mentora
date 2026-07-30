import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mentora/application/booking/expert_booking_occupancy_application_service.dart';
import 'package:mentora/application/booking/expert_booking_occupancy_failure.dart';
import 'package:mentora/domain/booking/expert_booking_occupancy_repository.dart';
import 'package:mentora/infrastructure/booking/firestore_expert_booking_occupancy_repository.dart';

const _projectId = 'mentora-7e926';
final _expectedEmulatorHost = Platform.isAndroid
    ? '10.0.2.2:8080'
    : '127.0.0.1:8080';
const _configuredEmulatorHost = String.fromEnvironment(
  'FIRESTORE_EMULATOR_HOST',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('reads only Genesis occupancy facts from Firestore Emulator', (
    tester,
  ) async {
    if (_configuredEmulatorHost != _expectedEmulatorHost) {
      fail(
        'FIRESTORE_EMULATOR_HOST must be $_expectedEmulatorHost, '
        'got ${_configuredEmulatorHost.isEmpty ? "<absent>" : _configuredEmulatorHost}.',
      );
    }

    final app = await Firebase.initializeApp(
      name: 'expert-booking-occupancy-emulator',
      options: const FirebaseOptions(
        apiKey: 'emulator-only',
        appId: '1:1:android:emulator',
        messagingSenderId: '1',
        projectId: _projectId,
      ),
    );
    final firestore = FirebaseFirestore.instanceFor(app: app);
    final hostAndPort = _expectedEmulatorHost.split(':');
    firestore.useFirestoreEmulator(
      hostAndPort.first,
      int.parse(hostAndPort[1]),
    );

    final collection = firestore.collection('bookings');
    final marker = DateTime.now().microsecondsSinceEpoch.toString();
    final documents = <DocumentReference<Map<String, dynamic>>>[];

    Future<void> seed(
      String expertId,
      String status,
      String date,
      String time,
    ) async {
      final document = collection.doc('wave2c_${marker}_${documents.length}');
      documents.add(document);
      await document.set({
        'expertId': expertId,
        'status': status,
        'bookingDate': date,
        'bookingTime': time,
      });
    }

    try {
      await seed('expert_a_$marker', 'pending', 'Lundi', '09:00');
      await seed('expert_a_$marker', 'confirmed', 'Mardi', '10:00');
      await seed('expert_a_$marker', 'paid', 'Mercredi', '11:00');
      await seed('expert_a_$marker', 'completed', 'Jeudi', '12:00');
      await seed('expert_b_$marker', 'pending', 'Vendredi', '13:00');

      final repository = FirestoreExpertBookingOccupancyRepository(
        firestore: firestore,
      );
      final expertA = await repository.loadForExpert('expert_a_$marker');
      final empty = await repository.loadForExpert('expert_empty_$marker');

      expect(expertA.map((occupancy) => occupancy.slotIdentity).toSet(), {
        'Lundi|09:00',
        'Mardi|10:00',
        'Mercredi|11:00',
      });
      expect(empty, isEmpty);

      final malformed = collection.doc('wave2c_${marker}_malformed');
      documents.add(malformed);
      await malformed.set({
        'expertId': 'expert_malformed_$marker',
        'status': 'pending',
        'bookingTime': '14:00',
      });

      await expectLater(
        repository.loadForExpert('expert_malformed_$marker'),
        throwsA(
          isA<ExpertBookingOccupancyRepositoryException>().having(
            (error) => error.malformedData,
            'malformedData',
            isTrue,
          ),
        ),
      );

      final application = ExpertBookingOccupancyApplicationService(
        repository: repository,
      );
      await expectLater(
        application.loadForExpert('expert_malformed_$marker'),
        throwsA(isA<ExpertBookingOccupancyMalformedDataFailure>()),
      );
    } finally {
      for (final document in documents) {
        await document.delete();
      }
      await app.delete();
    }
  });
}
