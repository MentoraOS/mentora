import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Workspace composition governance — ARCH-004', () {
    test('ARC-A14 ServiceLocator does not own or distribute Workspace', () {
      final source = _readLib('core/di/service_locater.dart');
      const forbidden = <String>{
        'WorkspaceController',
        'WorkspaceRepository',
        'WorkspaceMemberRepository',
        'FirebaseWorkspaceRepository',
        'FirebaseWorkspaceMemberRepository',
      };

      final violations = forbidden.where(source.contains).toList()..sort();

      expect(
        violations,
        isEmpty,
        reason:
            'ServiceLocator must not compose or distribute Workspace: '
            '${violations.join(', ')}',
      );
    });

    test('ARC-A15 modern Workspace code does not access ServiceLocator', () {
      final violations = <String>[];

      for (final file in _modernWorkspaceFiles()) {
        final source = file.readAsStringSync();
        if (source.contains('ServiceLocator.get<') ||
            source.contains('ServiceLocator.contains<')) {
          violations.add(_relativeLibPath(file));
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Modern Workspace dependencies must be constructor-injected: '
            '${violations.join(', ')}',
      );
    });

    test('ARC-A16 no global WorkspaceBootstrap replacement exists', () {
      final violations = <String>[];
      final globalBootstrap = RegExp(
        r'\bclass\s+\w*WorkspaceBootstrap\b|'
        r'\bWorkspaceBootstrap\s*\.',
      );

      for (final file in _libDartFiles()) {
        if (globalBootstrap.hasMatch(file.readAsStringSync())) {
          violations.add(_relativeLibPath(file));
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Workspace refresh must remain an injected Application '
            'dependency: ${violations.join(', ')}',
      );
    });

    test(
      'ARC-A17 Presentation cannot construct concrete Workspace adapters',
      () {
        final violations = <String>[];
        final concreteConstruction = RegExp(
          r'\b[A-Z]\w*(?:Workspace|WorkspaceMember)Repository\s*\(',
        );

        for (final file in _presentationFiles()) {
          final source = file.readAsStringSync();
          if (source.contains('/infrastructure/workspace/') ||
              concreteConstruction.hasMatch(source)) {
            violations.add(_relativeLibPath(file));
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Presentation must depend on Workspace ports, never concrete '
              'adapters: ${violations.join(', ')}',
        );
      },
    );

    test('ARC-A18 Workspace adapters receive Firebase by constructor', () {
      final violations = <String>[];

      for (final file in _filesUnder('infrastructure/workspace')) {
        if (file.readAsStringSync().contains('FirebaseFirestore.instance')) {
          violations.add(_relativeLibPath(file));
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Workspace infrastructure must receive Firebase dependencies '
            'from the Composition Root: ${violations.join(', ')}',
      );
    });

    test('ARC-A19 Presentation cannot access legacy WorkspaceEngine', () {
      final violations = <String>[];

      for (final file in _presentationFiles()) {
        if (file.readAsStringSync().contains('WorkspaceEngine')) {
          violations.add(_relativeLibPath(file));
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Presentation must use the injected WorkspaceState port: '
            '${violations.join(', ')}',
      );
    });

    test(
      'ARC-A20 Workspace state owner is composed only in canonical root',
      () {
        final violations = <String>[];
        const allowed = 'composition/mentora_composition_root.dart';
        final construction = RegExp(r'\bDefaultWorkspaceState\s*\(');

        for (final file in _libDartFiles()) {
          final path = _relativeLibPath(file);
          final source = file.readAsStringSync();
          final isDeclaration = source.contains(
            'final class DefaultWorkspaceState',
          );

          if (path != allowed &&
              !isDeclaration &&
              construction.hasMatch(source)) {
            violations.add(path);
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'DefaultWorkspaceState production construction belongs only to '
              'MentoraCompositionRoot: ${violations.join(', ')}',
        );
      },
    );

    test('ARC-A21 Composition Root exposes one Workspace state owner', () {
      final root = _readLib('composition/mentora_composition_root.dart');
      final dependencies = _readLib('composition/mentora_dependencies.dart');

      expect(root, contains('final workspaceState = DefaultWorkspaceState('));
      expect(root, contains('workspaceState: workspaceState,'));
      expect(dependencies, contains('final WorkspaceState workspaceState;'));
      expect(dependencies, isNot(contains('DefaultWorkspaceState')));
    });
  });
}

String _readLib(String relativePath) {
  return File('${_projectRoot().path}/lib/$relativePath').readAsStringSync();
}

Iterable<File> _modernWorkspaceFiles() sync* {
  yield* _filesUnder('application/workspace');
  yield* _filesUnder('application/startup');
  yield* _filesUnder('infrastructure/workspace');
  yield* _filesUnder('presentation/controllers/workspace');
}

Iterable<File> _presentationFiles() sync* {
  yield* _filesUnder('presentation');
  yield* _filesUnder(
    'features',
    where: (path) => path.contains('/presentation/'),
  );
  yield* _filesUnder('screens');
}

Iterable<File> _filesUnder(
  String relativePath, {
  bool Function(String path)? where,
}) {
  final directory = Directory('${_projectRoot().path}/lib/$relativePath');
  if (!directory.existsSync()) {
    return const <File>[];
  }

  return directory
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => where?.call(_relativeLibPath(file)) ?? true);
}

Iterable<File> _libDartFiles() {
  return _filesUnder('');
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
