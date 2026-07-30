import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mentora/domain/expert_availability/expert_availability.dart';
import 'package:mentora/domain/expert_availability/expert_availability_repository.dart';
import 'package:mentora/infrastructure/expert_availability/firestore_expert_availability_repository.dart';

const _projectId = 'mentora-7e926';
const _androidTestAppName = 'expert-availability-emulator';
final _expectedEmulatorHost = Platform.isAndroid
    ? '10.0.2.2:8080'
    : '127.0.0.1:8080';
const _configuredEmulatorHost = String.fromEnvironment(
  'FIRESTORE_EMULATOR_HOST',
);
const _options = FirebaseOptions(
  apiKey: 'emulator-only-api-key',
  appId: '1:000000000000:android:emulator',
  messagingSenderId: '000000000000',
  projectId: _projectId,
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  FirebaseApp? clientAApp;
  var clientAppCreated = false;
  late FirebaseFirestore clientAFirestore;
  late FirestoreExpertAvailabilityRepository clientARepository;
  late FirestoreExpertAvailabilityRepository clientBRepository;
  var firebaseInitialized = false;

  setUpAll(() async {
    if (_configuredEmulatorHost != _expectedEmulatorHost) {
      throw StateError(
        'Refusing to run: FIRESTORE_EMULATOR_HOST must be '
        '$_expectedEmulatorHost, got '
        '${_configuredEmulatorHost.isEmpty ? "<absent>" : _configuredEmulatorHost}.',
      );
    }

    final expectedAppName = Platform.isAndroid
        ? _androidTestAppName
        : defaultFirebaseAppName;
    final existingTestApps = Firebase.apps.where(
      (app) => app.name == expectedAppName,
    );
    print('SETUP: Firebase test app initialization starting');
    final initializedClientA = existingTestApps.isEmpty
        ? await _atStage(
            'Firebase test app initialization',
            Firebase.initializeApp(
              name: Platform.isAndroid ? _androidTestAppName : null,
              options: _options,
            ),
          )
        : Firebase.app(expectedAppName);
    clientAppCreated = existingTestApps.isEmpty;
    print('SETUP: Firebase test app initialization completed');
    _expectEmulatorOnlyOptions(initializedClientA);

    clientAApp = initializedClientA;
    print('SETUP: FirebaseFirestore.instance starting');
    clientAFirestore = FirebaseFirestore.instanceFor(app: initializedClientA);
    print('SETUP: FirebaseFirestore.instance completed');
    final emulatorAddress = _expectedEmulatorHost.split(':');
    clientAFirestore.useFirestoreEmulator(
      emulatorAddress.first,
      int.parse(emulatorAddress.last),
    );
    print('SETUP: Firestore Emulator routing completed');
    clientARepository = FirestoreExpertAvailabilityRepository(
      firestore: clientAFirestore,
    );
    clientBRepository = FirestoreExpertAvailabilityRepository(
      firestore: clientAFirestore,
    );
    firebaseInitialized = true;
  });

  tearDownAll(() async {
    if (firebaseInitialized) {
      for (final expertId in const [
        'expert_emulator_connectivity_test',
        'expert_raw_transaction_probe_test',
        'expert_concurrency_test',
        'expert_first_availability_write_test',
        'expert_complete_replacement_test',
        'expert_empty_availability_test',
        'expert_sequential_writes_test',
        'expert_without_availability_test',
        'expert_malformed_availability_revision_test',
      ]) {
        await clientAFirestore.collection('experts').doc(expertId).delete();
      }
    }
    if (clientAppCreated && Platform.isAndroid) {
      await clientAApp?.delete();
    }
  });

  test('native harness initializes two independent repository clients', () {
    expect(firebaseInitialized, isTrue);
    expect(clientAApp, isNotNull);
    expect(clientARepository, isNot(same(clientBRepository)));
  });

  test('connects exclusively to the Firestore Emulator', () async {
    const expertId = 'expert_emulator_connectivity_test';
    final document = clientAFirestore.collection('experts').doc(expertId);

    await document.set(const <String, dynamic>{
      'sentinel': 'emulator-connectivity',
    });
    final persisted = await document.get(
      const GetOptions(source: Source.server),
    );

    expect(persisted.data()?['sentinel'], 'emulator-connectivity');
  });

  test(
    'native Firestore transaction probe commits a server timestamp',
    () async {
      const expertId = 'expert_raw_transaction_probe_test';
      final document = clientAFirestore.collection('experts').doc(expertId);

      await _atStage(
        'raw probe seed',
        document.set(<String, dynamic>{
          'availabilityUpdatedAt': FieldValue.serverTimestamp(),
          'sentinel': 'raw-transaction-probe',
        }),
      );
      final before = await _atStage(
        'raw probe initial load',
        document.get(const GetOptions(source: Source.server)),
      );
      final revision1 = before.data()?['availabilityUpdatedAt'];
      expect(revision1, isA<Timestamp>());

      print('RAW_TRANSACTION_STARTED');
      await _atStage(
        'raw transaction commit',
        clientAFirestore.runTransaction<void>((transaction) async {
          print('CALLBACK_ENTERED');
          final snapshot = await transaction.get(document);
          print('TRANSACTION_GET_OK');
          expect(snapshot.data()?['availabilityUpdatedAt'], revision1);
          transaction.set(document, <String, dynamic>{
            'availabilityUpdatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          print('TRANSACTION_WRITE_OK');
        }),
      );
      print('TRANSACTION_COMMIT_OK');

      final after = await _atStage(
        'raw probe post-commit read',
        document.get(const GetOptions(source: Source.server)),
      );
      final revision2 = after.data()?['availabilityUpdatedAt'];
      expect(revision2, isA<Timestamp>());
      expect(revision2, isNot(revision1));
      expect(after.data()?['sentinel'], 'raw-transaction-probe');
      print('RAW_R1=$revision1');
      print('RAW_R2=$revision2');
    },
    timeout: const Timeout(Duration(minutes: 1)),
  );

  test(
    'rejects a stale writer and preserves the first transaction',
    () async {
      const expertId = 'expert_concurrency_test';
      final document = clientAFirestore.collection('experts').doc(expertId);
      await document.set(<String, dynamic>{
        'availability': <String, List<String>>{
          'Vendredi': <String>['17:00'],
        },
        'availabilityUpdatedAt': FieldValue.serverTimestamp(),
        'name': 'Expert Test',
        'country': 'ML',
        'sentinel': 'must-survive',
      });
      print('concurrency checkpoint: seed persisted');

      final seeded = await document.get(
        const GetOptions(source: Source.server),
      );
      expect(seeded.data()?['availabilityUpdatedAt'], isA<Timestamp>());
      print('concurrency checkpoint: seed revision loaded');

      final loadedA = await clientARepository.loadByExpertId(expertId);
      print('concurrency checkpoint: client A loaded R1');
      final loadedB = await clientBRepository.loadByExpertId(expertId);
      print('concurrency checkpoint: client B loaded R1');
      final revision1 = loadedA.revision;

      expect(revision1, isNotNull);
      expect(loadedB.revision, revision1);

      final availabilityA = ExpertAvailability(
        slotsByDay: const {
          'Lundi': ['08:00', '09:00'],
        },
        revision: revision1,
      );
      final savedA = await clientARepository.saveByExpertId(
        expertId: expertId,
        availability: availabilityA,
      );
      print('concurrency checkpoint: client A persisted R2');
      final revision2 = savedA.revision;

      expect(revision2, isNotNull);
      expect(revision2, isNot(revision1));

      final afterA = await document.get(
        const GetOptions(source: Source.server),
      );
      final afterAData = afterA.data()!;
      final storedTimestamp = afterAData['availabilityUpdatedAt'];
      expect(storedTimestamp, isA<Timestamp>());
      final timestamp = storedTimestamp as Timestamp;
      expect(revision2, '${timestamp.seconds}:${timestamp.nanoseconds}');
      _expectUnrelatedFields(afterAData);

      final availabilityB = ExpertAvailability(
        slotsByDay: const {
          'Mardi': ['14:00'],
        },
        revision: loadedB.revision,
      );
      await expectLater(
        clientBRepository.saveByExpertId(
          expertId: expertId,
          availability: availabilityB,
        ),
        throwsA(
          isA<ExpertAvailabilityConcurrencyException>()
              .having(
                (error) => error.expectedRevision,
                'expectedRevision',
                revision1,
              )
              .having(
                (error) => error.actualRevision,
                'actualRevision',
                revision2,
              ),
        ),
      );
      print('concurrency checkpoint: stale client B rejected');

      final finalAvailability = await clientBRepository.loadByExpertId(
        expertId,
      );
      expect(finalAvailability.slotsByDay, availabilityA.slotsByDay);
      expect(finalAvailability.slotsByDay, isNot(availabilityB.slotsByDay));
      expect(finalAvailability.revision, revision2);

      final finalDocument = await document.get(
        const GetOptions(source: Source.server),
      );
      _expectUnrelatedFields(finalDocument.data()!);
      print('concurrency checkpoint: final state verified');
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test('first write with null revision creates a server revision', () async {
    const expertId = 'expert_first_availability_write_test';
    final document = clientAFirestore.collection('experts').doc(expertId);
    await document.set(<String, dynamic>{
      'name': 'First Writer',
      'country': 'ML',
      'sentinel': 'must-survive',
    });

    final loaded = await clientARepository.loadByExpertId(expertId);
    expect(loaded.revision, isNull);

    final saved = await clientARepository.saveByExpertId(
      expertId: expertId,
      availability: ExpertAvailability(
        slotsByDay: const {
          'Samedi': ['10:00'],
        },
      ),
    );

    expect(saved.revision, isNotNull);
    final persisted = await document.get(
      const GetOptions(source: Source.server),
    );
    final data = persisted.data()!;
    final storedTimestamp = data['availabilityUpdatedAt'];
    expect(storedTimestamp, isA<Timestamp>());
    final timestamp = storedTimestamp as Timestamp;
    expect(saved.revision, '${timestamp.seconds}:${timestamp.nanoseconds}');
    _expectUnrelatedFields(data, name: 'First Writer');
  });

  test('replaces the complete availability map', () async {
    const expertId = 'expert_complete_replacement_test';
    final document = clientAFirestore.collection('experts').doc(expertId);
    await document.set(<String, dynamic>{
      'availability': <String, List<String>>{
        'Lundi': <String>['08:00'],
        'Mardi': <String>['09:00'],
      },
      'availabilityUpdatedAt': FieldValue.serverTimestamp(),
      'name': 'Replacement Expert',
      'country': 'ML',
      'sentinel': 'must-survive',
    });

    final loaded = await clientARepository.loadByExpertId(expertId);
    final saved = await clientARepository.saveByExpertId(
      expertId: expertId,
      availability: ExpertAvailability(
        slotsByDay: const {
          'Mercredi': ['10:00'],
          'Jeudi': ['11:00'],
        },
        revision: loaded.revision,
      ),
    );

    expect(saved.slotsByDay, {
      'Mercredi': ['10:00'],
      'Jeudi': ['11:00'],
    });
    final data = (await document.get(
      const GetOptions(source: Source.server),
    )).data()!;
    expect(data['availability'], {
      'Mercredi': ['10:00'],
      'Jeudi': ['11:00'],
    });
    _expectUnrelatedFields(data, name: 'Replacement Expert');
  });

  test(
    'persists an empty availability map as a complete replacement',
    () async {
      const expertId = 'expert_empty_availability_test';
      final document = clientAFirestore.collection('experts').doc(expertId);
      await document.set(<String, dynamic>{
        'availability': <String, List<String>>{
          'Lundi': <String>['08:00'],
        },
        'availabilityUpdatedAt': FieldValue.serverTimestamp(),
        'name': 'Empty Availability Expert',
        'country': 'ML',
        'sentinel': 'must-survive',
      });

      final loaded = await clientARepository.loadByExpertId(expertId);
      final saved = await clientARepository.saveByExpertId(
        expertId: expertId,
        availability: ExpertAvailability(
          slotsByDay: const <String, List<String>>{},
          revision: loaded.revision,
        ),
      );

      expect(saved.slotsByDay, isEmpty);
      final data = (await document.get(
        const GetOptions(source: Source.server),
      )).data()!;
      expect(data['availability'], isA<Map<Object?, Object?>>());
      expect(data['availability'], isEmpty);
      _expectUnrelatedFields(data, name: 'Empty Availability Expert');
    },
  );

  test('accepts sequential writes using each fresh revision', () async {
    const expertId = 'expert_sequential_writes_test';
    final document = clientAFirestore.collection('experts').doc(expertId);
    await document.set(<String, dynamic>{
      'availability': <String, List<String>>{
        'Lundi': <String>['08:00'],
      },
      'availabilityUpdatedAt': FieldValue.serverTimestamp(),
      'name': 'Sequential Expert',
      'country': 'ML',
      'sentinel': 'must-survive',
    });

    final initial = await clientARepository.loadByExpertId(expertId);
    final first = await clientARepository.saveByExpertId(
      expertId: expertId,
      availability: ExpertAvailability(
        slotsByDay: const {
          'Mardi': ['09:00'],
        },
        revision: initial.revision,
      ),
    );
    final second = await clientARepository.saveByExpertId(
      expertId: expertId,
      availability: ExpertAvailability(
        slotsByDay: const {
          'Mercredi': ['10:00'],
        },
        revision: first.revision,
      ),
    );

    expect(first.revision, isNot(initial.revision));
    expect(second.revision, isNot(first.revision));
    expect(second.slotsByDay, {
      'Mercredi': ['10:00'],
    });
    final data = (await document.get(
      const GetOptions(source: Source.server),
    )).data()!;
    expect(data['availability'], {
      'Mercredi': ['10:00'],
    });
    _expectUnrelatedFields(data, name: 'Sequential Expert');
  });

  test('loads an existing Expert without availability as empty', () async {
    const expertId = 'expert_without_availability_test';
    final document = clientAFirestore.collection('experts').doc(expertId);
    await document.set(const <String, dynamic>{
      'name': 'No Availability Expert',
      'country': 'ML',
      'sentinel': 'must-survive',
    });

    final loaded = await clientARepository.loadByExpertId(expertId);

    expect(loaded.slotsByDay, isEmpty);
    expect(loaded.revision, isNull);
  });

  test('malformed revision is rejected as malformed repository data', () async {
    const expertId = 'expert_malformed_availability_revision_test';
    final document = clientAFirestore.collection('experts').doc(expertId);
    await document.set(<String, dynamic>{
      'availability': <String, List<String>>{
        'Lundi': <String>['08:00'],
      },
      'availabilityUpdatedAt': 'not-a-timestamp',
    });

    await expectLater(
      clientARepository.loadByExpertId(expertId),
      throwsA(
        isA<ExpertAvailabilityRepositoryException>().having(
          (error) => error.malformedData,
          'malformedData',
          isTrue,
        ),
      ),
    );
  });
}

Future<T> _atStage<T>(String stage, Future<T> operation) async {
  try {
    return await operation.timeout(const Duration(seconds: 15));
  } on TimeoutException {
    print('FAILED STAGE: $stage');
    rethrow;
  }
}

void _expectEmulatorOnlyOptions(FirebaseApp app) {
  expect(app.options.projectId, _projectId);
  expect(app.options.apiKey, 'emulator-only-api-key');
  expect(app.options.appId, '1:000000000000:android:emulator');
}

void _expectUnrelatedFields(
  Map<String, dynamic> data, {
  String name = 'Expert Test',
}) {
  expect(data['name'], name);
  expect(data['country'], 'ML');
  expect(data['sentinel'], 'must-survive');
}
