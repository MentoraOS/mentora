import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Expert Catalog infrastructure boundary — ARCH-007 Wave 2A', () {
    test('ARC-A41 Expert Catalog Domain and Application are Firebase-free', () {
      final violations = <String>[];

      for (final root in const [
        'domain/expert_catalog',
        'application/expert_catalog',
      ]) {
        for (final file in _filesUnder(root)) {
          final source = file.readAsStringSync();
          if (source.contains('package:cloud_firestore/') ||
              source.contains('package:firebase_') ||
              source.contains('FirebaseFirestore') ||
              source.contains('DocumentSnapshot') ||
              source.contains('QuerySnapshot') ||
              source.contains('Timestamp')) {
            violations.add(_relativeLibPath(file));
          }
        }
      }

      expect(violations, isEmpty);
    });

    test('ARC-A42 Client Dashboard contains no Firebase dependency', () {
      final source = _readLib('screens/client_dashboard_screen.dart');

      expect(source, isNot(contains('package:cloud_firestore/')));
      expect(source, isNot(contains('package:firebase_')));
      expect(source, isNot(contains('FirebaseFirestore.instance')));
      expect(source, isNot(contains('DocumentSnapshot')));
      expect(source, isNot(contains('QuerySnapshot')));
    });

    test(
      'ARC-A43 Expert Detail performs no direct Catalog or Booking access',
      () {
        final source = _readLib('screens/expert_detail_screen.dart');

        expect(source, isNot(contains("collection('experts')")));
        expect(source, isNot(contains("collection('bookings')")));
        expect(source, contains('final ExpertCatalogEntry expert;'));
        expect(source, contains('ExpertBookingOccupancyApplicationService'));
      },
    );

    test('ARC-A44 Catalog adapter receives Firestore by constructor', () {
      final source = _readLib(
        'infrastructure/expert_catalog/'
        'firestore_expert_catalog_repository.dart',
      );

      expect(source, contains('required FirebaseFirestore firestore'));
      expect(source, isNot(contains('FirebaseFirestore.instance')));
      expect(source, isNot(matches(RegExp(r'\.firestore\s*\('))));
      expect(source, contains(".collection('experts')"));
      expect(source, isNot(contains('.where(')));
      expect(source, isNot(contains('.orderBy(')));
      expect(source, isNot(contains('.limit(')));
    });

    test('ARC-A45 Catalog adapter is constructed only in canonical root', () {
      const allowed = 'composition/mentora_composition_root.dart';
      final violations = <String>[];
      final construction = RegExp(r'\bFirestoreExpertCatalogRepository\s*\(');

      for (final file in _filesUnder('')) {
        final path = _relativeLibPath(file);
        final source = file.readAsStringSync();
        final declaration = source.contains(
          'final class FirestoreExpertCatalogRepository',
        );

        if (path != allowed && !declaration && construction.hasMatch(source)) {
          violations.add(path);
        }
      }

      expect(violations, isEmpty);
    });

    test('ARC-A46 Catalog avoids legacy and static composition', () {
      final root = _readLib('composition/mentora_composition_root.dart');
      final dependencies = _readLib('composition/mentora_dependencies.dart');
      final serviceLocator = _readLib('core/di/service_locater.dart');
      final enterpriseModule = _readLib(
        'core/di/modules/enterprise_module.dart',
      );
      final catalogSources = <String>[
        for (final root in const [
          'domain/expert_catalog',
          'application/expert_catalog',
          'infrastructure/expert_catalog',
        ])
          for (final file in _filesUnder(root)) file.readAsStringSync(),
      ].join('\n');

      expect(
        root,
        contains('final expertCatalog = ExpertCatalogApplicationService('),
      );
      expect(root, contains('expertCatalog: expertCatalog,'));
      expect(
        dependencies,
        contains('final ExpertCatalogApplicationService expertCatalog;'),
      );
      expect(dependencies, isNot(contains('FirestoreExpertCatalogRepository')));
      expect(serviceLocator, isNot(contains('ExpertCatalogRepository')));
      expect(enterpriseModule, isNot(contains('ExpertCatalogRepository')));
      expect(catalogSources, isNot(matches(RegExp(r'\.firestore\s*\('))));
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
