import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cross_domain_dependency_legacy_baseline.dart';
import 'dependency_direction_matrix.dart';
import 'domain_ownership_registry.dart';

void main() {
  group('Mentora Cross-Domain Dependencies — Sprint -1.2 / Lot D.4', () {
    test('ARC-D09 dependency matrix covers every registered owner', () {
      final missing =
          domainOwnershipRegistry
              .map((ownership) => ownership.domain)
              .where(
                (domain) =>
                    !DependencyDirectionMatrix.allowed.containsKey(domain),
              )
              .map((domain) => domain.name)
              .toList()
            ..sort();

      expect(
        missing,
        isEmpty,
        reason: 'Missing dependency policy for: ${missing.join(', ')}',
      );
    });

    test(
      'ARC-D10 dependency matrix cannot allow self-dependencies explicitly',
      () {
        final violations = <String>[];

        for (final entry in DependencyDirectionMatrix.allowed.entries) {
          if (entry.value.contains(entry.key)) {
            violations.add(entry.key.name);
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Self-dependency is implicit and must not be listed: '
              '${violations.join(', ')}',
        );
      },
    );

    test('ARC-D11 new forbidden cross-domain dependencies are blocked', () {
      final current = _scanForbiddenCrossDomainDependencies();
      final newViolations =
          current
              .difference(CrossDomainDependencyLegacyBaseline.violations)
              .toList()
            ..sort();

      expect(newViolations, isEmpty, reason: _failureMessage(newViolations));
    });
  });
}

Set<String> _scanForbiddenCrossDomainDependencies() {
  final root = _projectRoot();
  final lib = Directory('${root.path}/lib');
  final findings = <String>{};

  final files = lib
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));

  final importPattern = RegExp("import\\s+['\\\"]([^'\\\"]+)['\\\"]");

  for (final sourceFile in files) {
    final sourcePath = _relative(root, sourceFile);
    final sourceDomain = _domainForPath(sourcePath);

    if (sourceDomain == null) {
      continue;
    }

    final sourceText = sourceFile.readAsStringSync();

    for (final match in importPattern.allMatches(sourceText)) {
      final uri = match.group(1)!;
      final targetFile = _resolveImport(root, sourceFile, uri);

      if (targetFile == null || !targetFile.existsSync()) {
        continue;
      }

      final targetPath = _relative(root, targetFile);
      final targetDomain = _domainForPath(targetPath);

      if (targetDomain == null || targetDomain == sourceDomain) {
        continue;
      }

      if (DependencyDirectionMatrix.isAllowed(
        source: sourceDomain,
        target: targetDomain,
      )) {
        continue;
      }

      findings.add(
        '${sourceDomain.name}|${targetDomain.name}|$sourcePath|$uri',
      );
    }
  }

  return findings;
}

MentoraDomain? _domainForPath(String path) {
  for (final ownership in domainOwnershipRegistry) {
    if (path.startsWith('lib/core/${ownership.root}/')) {
      return ownership.domain;
    }
  }

  return null;
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
      throw StateError('Unable to locate Mentora project root.');
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

String _failureMessage(List<String> violations) {
  if (violations.isEmpty) {
    return '';
  }

  final buffer = StringBuffer()
    ..writeln('ARC-D11 introduced forbidden cross-domain dependency(ies).')
    ..writeln()
    ..writeln('Existing Lot A debt is grandfathered.')
    ..writeln('New forbidden directions are not allowed.')
    ..writeln()
    ..writeln('Do not add entries to the legacy baseline as a shortcut.')
    ..writeln()
    ..writeln('Violation(s):');

  for (final violation in violations) {
    buffer.writeln(' - $violation');
  }

  return buffer.toString();
}
