import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Mentora startup orchestration governance', () {
    test('ARC-A09 no legacy bootstrap configuration remains', () {
      final violations = _bootstrapConfigurationCallers().toList()..sort();

      expect(
        violations,
        isEmpty,
        reason:
            'Application startup must use injected gateways, not global '
            'bootstrap configuration: ${violations.join(', ')}',
      );
    });

    test('ARC-A10 production code no longer calls SessionBootstrapper', () {
      final violations = _filesContaining('SessionBootstrapper').toList()
        ..sort();

      expect(
        violations,
        isEmpty,
        reason:
            'MentoraStartup is the only production Session + Workspace '
            'startup orchestrator: ${violations.join(', ')}',
      );
    });

    test('ARC-A11 WorkspaceBootstrap global boundary is retired', () {
      final root = _projectRoot();
      final bootstrap = File(
        '${root.path}/lib/core/bootstrap/workspace_bootstrap.dart',
      );
      final violations = _filesContaining('WorkspaceBootstrap').toList()
        ..sort();

      expect(bootstrap.existsSync(), isFalse);
      expect(
        violations,
        isEmpty,
        reason:
            'Workspace refresh must be injected through an Application port: '
            '${violations.join(', ')}',
      );
    });

    test('ARC-A12 main delegates startup to the application service', () {
      final root = _projectRoot();
      final source = File('${root.path}/lib/main.dart').readAsStringSync();

      expect(source, contains('dependencies.startup.execute()'));
      expect(source, isNot(contains('SessionBootstrapper')));
      expect(source, isNot(contains('WorkspaceBootstrap')));
      expect(source, isNot(contains('sessionRepository:')));
      expect(source, isNot(contains('workspaceRepository:')));
    });

    test(
      'ARC-A13 startup Application boundary has no outward legacy imports',
      () {
        final root = _projectRoot();
        final application = Directory('${root.path}/lib/application/startup');
        final violations = <String>[];
        final forbiddenImports = <String>{
          '/presentation/',
          '/screens/',
          '/composition/',
          '/core/di/',
          '/infrastructure/',
          'package:firebase_',
          'package:cloud_firestore/',
          'package:agora_',
        };

        for (final file
            in application
                .listSync(recursive: true, followLinks: false)
                .whereType<File>()
                .where((file) => file.path.endsWith('.dart'))) {
          final source = file.readAsStringSync();

          for (final forbiddenImport in forbiddenImports) {
            if (source.contains(forbiddenImport)) {
              violations.add('${_relativeLibPath(file)}|$forbiddenImport');
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Application startup must depend only on its own ports and '
              'models: ${violations.join(', ')}',
        );
      },
    );
  });
}

Set<String> _bootstrapConfigurationCallers() {
  final findings = <String>{};

  for (final file in _libDartFiles()) {
    final source = file.readAsStringSync();

    if (source.contains('SessionBootstrapper.configure(') ||
        source.contains('WorkspaceBootstrap.configure(')) {
      findings.add(_relativeLibPath(file));
    }
  }

  return findings;
}

Set<String> _filesContaining(String pattern) {
  return _libDartFiles()
      .where((file) => file.readAsStringSync().contains(pattern))
      .map(_relativeLibPath)
      .toSet();
}

Iterable<File> _libDartFiles() {
  final root = _projectRoot();

  return Directory('${root.path}/lib')
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

String _relativeLibPath(File file) {
  final root = _projectRoot();
  final libPath = Directory('${root.path}/lib').absolute.path;
  final filePath = file.absolute.path;
  var relativePath = filePath.substring(libPath.length);

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
