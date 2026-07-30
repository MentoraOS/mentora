import 'dart:io';

import 'infrastructure_boundary_registry.dart';
import 'composition_root_registry.dart';

/// Represents one concrete infrastructure SDK import discovered in source code.
final class InfrastructureImport {
  const InfrastructureImport({
    required this.sourcePath,
    required this.importUri,
    required this.technology,
    required this.isAllowed,
  });

  final String sourcePath;
  final String importUri;
  final InfrastructureTechnology technology;
  final bool isAllowed;

  String get fingerprint => '${technology.name}|$sourcePath|$importUri';

  @override
  String toString() => fingerprint;
}

/// Scans Mentora source files for concrete infrastructure SDK imports.
///
/// Sprint -1.2 / Lot E.
///
/// This scanner does not decide whether legacy debt is acceptable.
/// It only discovers imports and evaluates them against the official
/// infrastructure boundary registry.
final class InfrastructureLeakScanner {
  InfrastructureLeakScanner({Directory? projectRoot})
    : projectRoot = projectRoot ?? Directory.current;

  final Directory projectRoot;

  List<InfrastructureImport> scan() {
    final libDirectory = Directory(
      '${projectRoot.path}${Platform.pathSeparator}lib',
    );

    if (!libDirectory.existsSync()) {
      throw StateError(
        'Unable to scan infrastructure boundaries: '
        'lib/ directory was not found at ${libDirectory.path}.',
      );
    }

    final violations = <InfrastructureImport>[];

    for (final entity in libDirectory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final sourcePath = _relativeLibPath(entity);

      if (CompositionRootRegistry.isAllowedCompositionRoot(sourcePath)) {
        continue;
      }

      final content = entity.readAsStringSync();

      for (final importUri in _extractPackageImports(content)) {
        final boundary = _boundaryFor(importUri);

        if (boundary == null) {
          continue;
        }

        final isAllowed = _isAllowed(
          sourcePath: sourcePath,
          boundary: boundary,
        );

        violations.add(
          InfrastructureImport(
            sourcePath: sourcePath,
            importUri: importUri,
            technology: boundary.technology,
            isAllowed: isAllowed,
          ),
        );
      }
    }

    violations.sort((a, b) => a.fingerprint.compareTo(b.fingerprint));

    return List.unmodifiable(violations);
  }

  List<InfrastructureImport> scanViolations() {
    return List.unmodifiable(scan().where((result) => !result.isAllowed));
  }

  InfrastructureBoundary? _boundaryFor(String importUri) {
    for (final boundary in infrastructureBoundaryRegistry) {
      for (final prefix in boundary.packagePrefixes) {
        if (importUri.startsWith(prefix)) {
          return boundary;
        }
      }
    }

    return null;
  }

  bool _isAllowed({
    required String sourcePath,
    required InfrastructureBoundary boundary,
  }) {
    for (final allowedRoot in boundary.allowedRootPrefixes) {
      if (sourcePath.startsWith(allowedRoot)) {
        return true;
      }
    }

    return false;
  }

  String _relativeLibPath(File file) {
    final libRoot = Directory(
      '${projectRoot.path}${Platform.pathSeparator}lib',
    ).absolute.path;

    final absoluteFilePath = file.absolute.path;

    var relativePath = absoluteFilePath.substring(libRoot.length);

    while (relativePath.startsWith('/') || relativePath.startsWith('\\')) {
      relativePath = relativePath.substring(1);
    }

    return relativePath.replaceAll('\\', '/');
  }

  Iterable<String> _extractPackageImports(String content) sync* {
    final importPattern = RegExp(
      r'''import\s+['"]([^'"]+)['"]''',
      multiLine: true,
    );

    for (final match in importPattern.allMatches(content)) {
      final uri = match.group(1);

      if (uri != null && uri.startsWith('package:')) {
        yield uri;
      }
    }
  }
}
