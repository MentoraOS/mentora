import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'public_boundary_legacy_baseline.dart';

void main() {
  group('Mentora Public Module Boundaries — Sprint -1.2 / Lot C', () {
    test('ARC-C01 required public facade files exist', () {
      final root = _projectRoot();

      const modules = {
        'booking',
        'scheduling',
        'payment',
        'consultation',
        'meeting',
        'identity',
        'notification',
        'financial',
      };

      final missing = <String>[];

      for (final module in modules) {
        final facade = File('${root.path}/lib/core/$module/$module.dart');

        if (!facade.existsSync()) {
          missing.add('lib/core/$module/$module.dart');
        }
      }

      expect(
        missing,
        isEmpty,
        reason: 'Missing public module facade(s): ${missing.join(', ')}',
      );
    });

    test(
      'ARC-C02 no new external direct import of critical module internals',
      () {
        final current = _directInternalImports();

        final newViolations =
            current
                .difference(PublicBoundaryLegacyBaseline.directInternalImports)
                .toList()
              ..sort();

        expect(
          newViolations,
          isEmpty,
          reason: _message(
            'ARC-C02',
            'External modules must import the module public facade.',
            newViolations,
          ),
        );
      },
    );

    test(
      'ARC-C03 Financial public facade exposes no engine or persistence implementation',
      () {
        final root = _projectRoot();
        final facade = File('${root.path}/lib/core/financial/financial.dart');

        final source = facade.readAsStringSync();

        const forbiddenSegments = {
          '/ledger/',
          '/pipeline/',
          '/orchestrator/',
          '/runtime/',
          '/workflow/',
          '/infrastructure/',
          'memory_',
          'firestore_',
        };

        final findings = forbiddenSegments.where(source.contains).toList()
          ..sort();

        expect(
          findings,
          isEmpty,
          reason:
              'Financial public API must not export engine/persistence internals: '
              '${findings.join(', ')}',
        );
      },
    );

    test('ARC-C04 public facades do not export concrete memory repositories', () {
      final root = _projectRoot();

      const modules = {
        'booking',
        'payment',
        'consultation',
        'meeting',
        'notification',
      };

      final violations = <String>[];

      for (final module in modules) {
        final file = File('${root.path}/lib/core/$module/$module.dart');
        final source = file.readAsStringSync();

        if (source.contains('memory_')) {
          violations.add('lib/core/$module/$module.dart');
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Public APIs must expose repository contracts, not memory adapters: '
            '${violations.join(', ')}',
      );
    });
  });
}

const _criticalModules = {
  'booking',
  'scheduling',
  'payment',
  'consultation',
  'meeting',
  'identity',
  'notification',
  'financial',
};

Set<String> _directInternalImports() {
  final root = _projectRoot();
  final lib = Directory('${root.path}/lib');
  final findings = <String>{};

  final dartFiles = lib
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));

  final importPattern = RegExp("import\\s+['\"]([^'\"]+)['\"]");

  for (final sourceFile in dartFiles) {
    final sourcePath = _relative(root, sourceFile);
    final source = sourceFile.readAsStringSync();

    for (final match in importPattern.allMatches(source)) {
      final uri = match.group(1)!;
      final target = _resolveImport(root, sourceFile, uri);

      if (target == null || !target.existsSync()) {
        continue;
      }

      final targetPath = _relative(root, target);

      for (final module in _criticalModules) {
        final modulePrefix = 'lib/core/$module/';

        if (!targetPath.startsWith(modulePrefix)) {
          continue;
        }

        if (sourcePath.startsWith(modulePrefix)) {
          break;
        }

        final facade = 'lib/core/$module/$module.dart';

        if (targetPath == facade) {
          break;
        }

        findings.add('$module|$sourcePath|$uri');
        break;
      }
    }
  }

  return findings;
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

String _relative(Directory root, File file) {
  final rootPath = root.absolute.path.replaceAll('\\', '/');
  final filePath = file.absolute.path.replaceAll('\\', '/');

  return filePath.substring(rootPath.length + 1);
}

File? _resolveImport(Directory root, File sourceFile, String uri) {
  if (uri.startsWith('dart:')) {
    return null;
  }

  if (uri.startsWith('package:')) {
    const prefix = 'package:mentora/';

    if (!uri.startsWith(prefix)) {
      return null;
    }

    return File('${root.path}/lib/${uri.substring(prefix.length)}');
  }

  return File.fromUri(sourceFile.parent.uri.resolve(uri));
}

String _message(String rule, String policy, List<String> violations) {
  if (violations.isEmpty) {
    return '';
  }

  final buffer = StringBuffer()
    ..writeln('$rule failed.')
    ..writeln(policy)
    ..writeln()
    ..writeln('Existing legacy imports are grandfathered.')
    ..writeln('New internal imports are forbidden.')
    ..writeln()
    ..writeln('Use:')
    ..writeln("  import 'package:mentora/core/<module>/<module>.dart';")
    ..writeln()
    ..writeln('New violation(s):');

  for (final violation in violations) {
    buffer.writeln(' - $violation');
  }

  return buffer.toString();
}
