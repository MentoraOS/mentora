import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Session and Authentication boundary — ARCH-006', () {
    test('ARC-A22 Application authentication has no Firebase dependency', () {
      final violations = _filesUnder('application/authentication')
          .where((file) {
            final source = file.readAsStringSync();
            return source.contains('package:firebase_') ||
                source.contains('FirebaseAuth') ||
                source.contains('FirebaseFirestore');
          })
          .map(_relativeLibPath)
          .toList();

      expect(violations, isEmpty);
    });

    test('ARC-A23 Presentation has no direct Firebase Auth session access', () {
      final violations = <String>[];
      for (final file in _presentationFiles()) {
        final source = file.readAsStringSync();
        if (source.contains('package:firebase_auth/') ||
            source.contains('FirebaseAuth.instance')) {
          violations.add(_relativeLibPath(file));
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Presentation must consume AuthenticationSession: '
            '${violations.join(', ')}',
      );
    });

    test('ARC-A24 static SessionEngine authority is retired', () {
      final violations = <String>[];
      for (final file in _libDartFiles()) {
        if (file.readAsStringSync().contains('SessionEngine')) {
          violations.add(_relativeLibPath(file));
        }
      }

      expect(violations, isEmpty);
      expect(
        File(
          '${_projectRoot().path}/lib/core/session/session_engine.dart',
        ).existsSync(),
        isFalse,
      );
    });

    test('ARC-A25 global authentication binding is retired', () {
      final violations = <String>[];
      final globalBinding = RegExp(
        r'\blate\s+AuthenticationService\s+authenticationService\b',
      );

      for (final file in _libDartFiles()) {
        if (globalBinding.hasMatch(file.readAsStringSync())) {
          violations.add(_relativeLibPath(file));
        }
      }

      expect(violations, isEmpty);
    });

    test('ARC-A26 session owner is composed only in canonical root', () {
      final violations = <String>[];
      const allowed = 'composition/mentora_composition_root.dart';
      final construction = RegExp(r'\bDefaultAuthenticationSession\s*\(');

      for (final file in _libDartFiles()) {
        final path = _relativeLibPath(file);
        final source = file.readAsStringSync();
        final declaration = source.contains(
          'final class DefaultAuthenticationSession',
        );

        if (path != allowed && !declaration && construction.hasMatch(source)) {
          violations.add(path);
        }
      }

      expect(violations, isEmpty);
    });

    test('ARC-A27 Composition exposes the abstract session boundary', () {
      final root = _readLib('composition/mentora_composition_root.dart');
      final dependencies = _readLib('composition/mentora_dependencies.dart');

      expect(
        root,
        contains('final authenticationSession = DefaultAuthenticationSession('),
      );
      expect(
        dependencies,
        contains('final AuthenticationSession authenticationSession;'),
      );
      expect(dependencies, isNot(contains('DefaultAuthenticationSession')));
    });

    test('ARC-A28 Workspace Application boundary remains Firebase-free', () {
      final violations = _filesUnder('application/workspace')
          .where((file) {
            final source = file.readAsStringSync();
            return source.contains('package:firebase_') ||
                source.contains('FirebaseAuth');
          })
          .map(_relativeLibPath)
          .toList();

      expect(violations, isEmpty);
    });
  });
}

String _readLib(String relativePath) {
  return File('${_projectRoot().path}/lib/$relativePath').readAsStringSync();
}

Iterable<File> _presentationFiles() sync* {
  yield* _filesUnder('presentation');
  yield* _filesUnder('screens');
  yield* _filesUnder(
    'features',
    where: (path) => path.contains('/presentation/'),
  );
}

Iterable<File> _libDartFiles() => _filesUnder('');

Iterable<File> _filesUnder(
  String relativePath, {
  bool Function(String path)? where,
}) {
  final directory = Directory('${_projectRoot().path}/lib/$relativePath');
  if (!directory.existsSync()) return const <File>[];

  return directory
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => where?.call(_relativeLibPath(file)) ?? true);
}

String _relativeLibPath(File file) {
  final libPath = Directory('${_projectRoot().path}/lib').absolute.path;
  var relative = file.absolute.path.substring(libPath.length);
  while (relative.startsWith('/') || relative.startsWith('\\')) {
    relative = relative.substring(1);
  }
  return relative.replaceAll('\\', '/');
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
