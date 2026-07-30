import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/expert_availability/expert_availability_repository.dart';
import 'package:mentora/infrastructure/expert_availability/firestore_expert_availability_repository.dart';

void main() {
  group('ExpertAvailabilityRevisionGuard', () {
    const guard = ExpertAvailabilityRevisionGuard();

    test('accepts matching revisions', () {
      expect(
        () =>
            guard.ensureCurrent(expectedRevision: '1:2', actualRevision: '1:2'),
        returnsNormally,
      );
    });

    test('accepts the first write when both revisions are null', () {
      expect(
        () => guard.ensureCurrent(expectedRevision: null, actualRevision: null),
        returnsNormally,
      );
    });

    test('rejects a stale revision', () {
      expect(
        () =>
            guard.ensureCurrent(expectedRevision: '1:2', actualRevision: '3:4'),
        throwsA(
          isA<ExpertAvailabilityConcurrencyException>()
              .having(
                (error) => error.expectedRevision,
                'expectedRevision',
                '1:2',
              )
              .having((error) => error.actualRevision, 'actualRevision', '3:4'),
        ),
      );
    });

    test('rejects a competing first write that created a revision', () {
      expect(
        () =>
            guard.ensureCurrent(expectedRevision: null, actualRevision: '3:4'),
        throwsA(isA<ExpertAvailabilityConcurrencyException>()),
      );
    });
  });

  group('FirestoreExpertAvailabilityRepository production contract', () {
    final source = File(
      '${_projectRoot().path}/lib/infrastructure/expert_availability/'
      'firestore_expert_availability_repository.dart',
    ).readAsStringSync();

    test('uses the exact experts/{expertId} document path', () {
      expect(
        source,
        contains("_firestore.collection('experts').doc(expertId)"),
      );
    });

    test('loads without creating an absent document', () {
      final loadBody = source.substring(
        source.indexOf('Future<ExpertAvailability> loadByExpertId'),
        source.indexOf('@override', source.indexOf('loadByExpertId') + 1),
      );

      expect(loadBody, contains('.get()'));
      expect(loadBody, isNot(contains('.set(')));
      expect(source, contains('if (!snapshot.exists)'));
    });

    test('replaces availability atomically and rereads the server', () {
      expect(source, contains('runTransaction<void>'));
      expect(source, contains('transaction.get(document)'));
      expect(source, contains('if (snapshot.exists)'));
      expect(source, contains('transaction.update(document, data)'));
      expect(source, contains('transaction.set('));
      expect(source, isNot(contains('SetOptions(merge: true)')));
      expect(source, contains('GetOptions(source: Source.server)'));
    });

    test('compares the transaction revision before writing', () {
      final comparison = source.indexOf('_revisionGuard.ensureCurrent(');
      final write = source.indexOf('transaction.update(');

      expect(comparison, greaterThan(0));
      expect(write, greaterThan(comparison));
    });
  });
}

Directory _projectRoot() {
  var current = Directory.current.absolute;

  while (true) {
    if (File('${current.path}/pubspec.yaml').existsSync() &&
        Directory('${current.path}/lib').existsSync()) {
      return current;
    }

    final parent = current.parent;
    if (parent.path == current.path) {
      throw StateError('Unable to locate project root.');
    }
    current = parent;
  }
}
