import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Favorites infrastructure boundary — ARCH-007 Wave 1B', () {
    test('ARC-A35 Favorites Domain and Application remain Firebase-free', () {
      final violations = <String>[];

      for (final root in const ['domain/favorites', 'application/favorites']) {
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

    test('ARC-A36 Favorites Presentation contains no Firebase dependency', () {
      final source = _readLib('screens/favorite_experts_screen.dart');

      expect(source, isNot(contains('package:cloud_firestore/')));
      expect(source, isNot(contains('package:firebase_')));
      expect(source, isNot(contains('FirebaseFirestore.instance')));
      expect(source, isNot(contains('FirebaseAuth.instance')));
      expect(source, isNot(contains('DocumentSnapshot')));
      expect(source, isNot(contains('QuerySnapshot')));
    });

    test('ARC-A37 Favorites adapter receives Firestore by constructor', () {
      final source = _readLib(
        'infrastructure/favorites/firestore_favorite_experts_repository.dart',
      );

      expect(source, contains('required FirebaseFirestore firestore'));
      expect(source, isNot(contains('FirebaseFirestore.instance')));
      expect(source, isNot(matches(RegExp(r'\.firestore\s*\('))));
    });

    test('ARC-A38 Favorites adapter is constructed only in canonical root', () {
      const allowed = 'composition/mentora_composition_root.dart';
      final violations = <String>[];
      final construction = RegExp(r'\bFirestoreFavoriteExpertsRepository\s*\(');

      for (final file in _filesUnder('')) {
        final path = _relativeLibPath(file);
        final source = file.readAsStringSync();
        final declaration = source.contains(
          'final class FirestoreFavoriteExpertsRepository',
        );

        if (path != allowed && !declaration && construction.hasMatch(source)) {
          violations.add(path);
        }
      }

      expect(violations, isEmpty);
    });

    test('ARC-A39 Composition exposes only Favorites Application', () {
      final root = _readLib('composition/mentora_composition_root.dart');
      final dependencies = _readLib('composition/mentora_dependencies.dart');

      expect(
        root,
        contains('final favoriteExperts = FavoriteExpertsApplicationService('),
      );
      expect(root, contains('favoriteExperts: favoriteExperts,'));
      expect(
        dependencies,
        contains('final FavoriteExpertsApplicationService favoriteExperts;'),
      );
      expect(
        dependencies,
        isNot(contains('FirestoreFavoriteExpertsRepository')),
      );
    });

    test('ARC-A40 Favorites avoids legacy and static composition', () {
      final serviceLocator = _readLib('core/di/service_locater.dart');
      final enterpriseModule = _readLib(
        'core/di/modules/enterprise_module.dart',
      );
      final favoritesSources = <String>[
        for (final root in const [
          'domain/favorites',
          'application/favorites',
          'infrastructure/favorites',
        ])
          for (final file in _filesUnder(root)) file.readAsStringSync(),
      ].join('\n');

      expect(serviceLocator, isNot(contains('FavoriteExpertsRepository')));
      expect(
        serviceLocator,
        isNot(contains('FavoriteExpertsApplicationService')),
      );
      expect(enterpriseModule, isNot(contains('FavoriteExpertsRepository')));
      expect(
        enterpriseModule,
        isNot(contains('FavoriteExpertsApplicationService')),
      );
      expect(favoritesSources, isNot(matches(RegExp(r'\.firestore\s*\('))));
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
