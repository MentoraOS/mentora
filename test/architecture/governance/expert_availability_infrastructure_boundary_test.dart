import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Expert Availability infrastructure boundary — ARCH-007 Wave 2B', () {
    test('ARC-A47 Domain and Application remain infrastructure-free', () {
      final violations = <String>[];

      for (final root in const [
        'domain/expert_availability',
        'application/expert_availability',
      ]) {
        for (final file in _filesUnder(root)) {
          final source = file.readAsStringSync();
          if (source.contains('package:cloud_firestore/') ||
              source.contains('package:firebase_') ||
              source.contains('FirebaseFirestore') ||
              source.contains('DocumentSnapshot') ||
              source.contains('QuerySnapshot') ||
              source.contains('Timestamp') ||
              source.contains('BuildContext') ||
              source.contains('package:flutter/')) {
            violations.add(_relativeLibPath(file));
          }
        }
      }

      expect(violations, isEmpty);
    });

    test('ARC-A48 Availability does not depend on Booking or Scheduling', () {
      final sources = <String>[
        for (final root in const [
          'domain/expert_availability',
          'application/expert_availability',
          'infrastructure/expert_availability',
        ])
          for (final file in _filesUnder(root)) file.readAsStringSync(),
      ].join('\n');

      expect(sources, isNot(contains('/booking/')));
      expect(sources, isNot(contains('/scheduling/')));
      expect(sources, isNot(contains('BookingEngine')));
      expect(sources, isNot(contains('SchedulingEngine')));
    });

    test('ARC-A49 Expert Agenda contains no Firebase dependency', () {
      final source = _readLib('screens/expert_agenda_screen.dart');

      expect(source, isNot(contains('package:cloud_firestore/')));
      expect(source, isNot(contains('package:firebase_')));
      expect(source, isNot(contains('FirebaseFirestore')));
      expect(source, isNot(contains('DocumentReference')));
      expect(source, isNot(contains('FieldValue')));
      expect(source, isNot(contains('SetOptions')));
      expect(source, isNot(contains('expertId')));
      expect(source, contains('ExpertAvailabilityApplicationService'));
    });

    test('ARC-A50 adapter is injected and protects revision atomically', () {
      final source = _readLib(
        'infrastructure/expert_availability/'
        'firestore_expert_availability_repository.dart',
      );

      expect(source, contains('required FirebaseFirestore firestore'));
      expect(source, isNot(contains('FirebaseFirestore.instance')));
      expect(source, isNot(matches(RegExp(r'\.firestore\s*\('))));
      expect(
        source,
        contains("_firestore.collection('experts').doc(expertId)"),
      );
      expect(source, contains('runTransaction<void>'));
      expect(source, contains('transaction.get(document)'));
      expect(source, contains('_revisionGuard.ensureCurrent('));
      expect(source, contains('if (snapshot.exists)'));
      expect(source, contains('transaction.update(document, data)'));
      expect(source, contains('transaction.set('));
      expect(source, isNot(contains('SetOptions(merge: true)')));
      expect(source, contains('GetOptions(source: Source.server)'));
    });

    test('ARC-A51 adapter is constructed only in canonical root', () {
      const allowed = 'composition/mentora_composition_root.dart';
      final violations = <String>[];
      final construction = RegExp(
        r'\bFirestoreExpertAvailabilityRepository\s*\(',
      );

      for (final file in _filesUnder('')) {
        final path = _relativeLibPath(file);
        final source = file.readAsStringSync();
        final declaration = source.contains(
          'final class FirestoreExpertAvailabilityRepository',
        );

        if (path != allowed && !declaration && construction.hasMatch(source)) {
          violations.add(path);
        }
      }

      expect(violations, isEmpty);
    });

    test('ARC-A52 composition exposes only the Application service', () {
      final root = _readLib('composition/mentora_composition_root.dart');
      final dependencies = _readLib('composition/mentora_dependencies.dart');
      final main = _readLib('main.dart');

      expect(
        root,
        contains(
          'final expertAvailability = ExpertAvailabilityApplicationService(',
        ),
      );
      expect(root, contains('expertAvailability: expertAvailability,'));
      expect(
        dependencies,
        contains(
          'final ExpertAvailabilityApplicationService expertAvailability;',
        ),
      );
      expect(
        dependencies,
        isNot(contains('FirestoreExpertAvailabilityRepository')),
      );
      expect(
        main,
        contains('Provider<ExpertAvailabilityApplicationService>.value('),
      );
    });

    test('ARC-A53 Availability avoids legacy composition mechanisms', () {
      final sources = <String>[
        for (final root in const [
          'domain/expert_availability',
          'application/expert_availability',
          'infrastructure/expert_availability',
        ])
          for (final file in _filesUnder(root)) file.readAsStringSync(),
      ].join('\n');

      expect(sources, isNot(contains('ServiceLocator')));
      expect(sources, isNot(contains('MentoraOS')));
      expect(sources, isNot(contains('EnterpriseModule')));
      expect(sources, isNot(matches(RegExp(r'\.firestore\s*\('))));
    });
  });
}

String _readLib(String relativePath) {
  return File('${_projectRoot().path}/lib/$relativePath').readAsStringSync();
}

Iterable<File> _filesUnder(String relativePath) {
  final directory = Directory('${_projectRoot().path}/lib/$relativePath');
  if (!directory.existsSync()) {
    return const <File>[];
  }

  return directory
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

String _relativeLibPath(File file) {
  final libPath = Directory('${_projectRoot().path}/lib').absolute.path;
  var relativePath = file.absolute.path.substring(libPath.length);

  while (relativePath.startsWith('/') || relativePath.startsWith('\\')) {
    relativePath = relativePath.substring(1);
  }

  return relativePath.replaceAll('\\', '/');
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
