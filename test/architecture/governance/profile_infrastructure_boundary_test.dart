import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Profile infrastructure boundary — ARCH-007 Wave 1A', () {
    test('ARC-A29 Profile Domain and Application remain Firebase-free', () {
      final violations = <String>[];

      for (final root in const ['domain/profile', 'application/profile']) {
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

    test('ARC-A30 Profile screens contain no Firebase dependency', () {
      final violations = <String>[];

      for (final path in const [
        'screens/profile_screen.dart',
        'screens/edit_profile_screen.dart',
      ]) {
        final source = _readLib(path);
        if (source.contains('package:cloud_firestore/') ||
            source.contains('package:firebase_auth/') ||
            source.contains('FirebaseFirestore.instance') ||
            source.contains('FirebaseAuth.instance')) {
          violations.add(path);
        }
      }

      expect(violations, isEmpty);
    });

    test('ARC-A31 Profile adapter receives Firestore by constructor', () {
      final source = _readLib(
        'infrastructure/profile/firestore_profile_repository.dart',
      );

      expect(source, contains('required FirebaseFirestore firestore'));
      expect(source, isNot(contains('FirebaseFirestore.instance')));
    });

    test('ARC-A32 Profile adapter is constructed only in canonical root', () {
      const allowed = 'composition/mentora_composition_root.dart';
      final violations = <String>[];
      final construction = RegExp(r'\bFirestoreProfileRepository\s*\(');

      for (final file in _filesUnder('')) {
        final path = _relativeLibPath(file);
        final source = file.readAsStringSync();
        final declaration = source.contains(
          'final class FirestoreProfileRepository',
        );

        if (path != allowed && !declaration && construction.hasMatch(source)) {
          violations.add(path);
        }
      }

      expect(violations, isEmpty);
    });

    test('ARC-A33 Composition exposes the Profile Application boundary', () {
      final root = _readLib('composition/mentora_composition_root.dart');
      final dependencies = _readLib('composition/mentora_dependencies.dart');

      expect(root, contains('final profile = ProfileApplicationService('));
      expect(root, contains('profile: profile,'));
      expect(
        dependencies,
        contains('final ProfileApplicationService profile;'),
      );
      expect(dependencies, isNot(contains('FirestoreProfileRepository')));
    });

    test('ARC-A34 Profile is absent from legacy composition mechanisms', () {
      final serviceLocator = _readLib('core/di/service_locater.dart');
      final enterpriseModule = _readLib(
        'core/di/modules/enterprise_module.dart',
      );

      expect(serviceLocator, isNot(contains('ProfileRepository')));
      expect(serviceLocator, isNot(contains('ProfileApplicationService')));
      expect(enterpriseModule, isNot(contains('ProfileRepository')));
      expect(enterpriseModule, isNot(contains('ProfileApplicationService')));
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
