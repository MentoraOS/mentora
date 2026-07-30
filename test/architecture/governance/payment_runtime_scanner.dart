import 'dart:io';

import 'payment_runtime_boundary_registry.dart';

final class PaymentRuntimeViolation {
  const PaymentRuntimeViolation({
    required this.sourcePath,
    required this.reason,
  });

  final String sourcePath;
  final String reason;

  String get fingerprint => '$sourcePath|$reason';

  @override
  String toString() => fingerprint;
}

final class PaymentRuntimeScanner {
  PaymentRuntimeScanner({Directory? projectRoot})
    : projectRoot = projectRoot ?? _discoverProjectRoot();

  final Directory projectRoot;

  List<PaymentRuntimeViolation> scan() {
    final libDirectory = Directory(
      '${projectRoot.path}${Platform.pathSeparator}lib',
    );

    if (!libDirectory.existsSync()) {
      throw StateError(
        'Unable to scan Payment runtime: '
        '${libDirectory.path} does not exist.',
      );
    }

    final violations = <PaymentRuntimeViolation>[];

    final files =
        libDirectory
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      final sourcePath = _relativeLibPath(file);

      if (PaymentRuntimeBoundaryRegistry.declarationFiles.contains(
        sourcePath,
      )) {
        continue;
      }

      final source = file.readAsStringSync();

      _scanForbiddenImports(
        source: source,
        sourcePath: sourcePath,
        violations: violations,
      );

      _scanForbiddenSymbols(
        source: source,
        sourcePath: sourcePath,
        violations: violations,
      );
    }

    final unique = <String, PaymentRuntimeViolation>{};

    for (final violation in violations) {
      unique[violation.fingerprint] = violation;
    }

    final result = unique.values.toList()
      ..sort((a, b) => a.fingerprint.compareTo(b.fingerprint));

    return List.unmodifiable(result);
  }

  void _scanForbiddenImports({
    required String source,
    required String sourcePath,
    required List<PaymentRuntimeViolation> violations,
  }) {
    final importPattern = RegExp(r'''import\s+['"]([^'"]+)['"]''');

    for (final match in importPattern.allMatches(source)) {
      final uri = match.group(1);

      if (uri == null) {
        continue;
      }

      for (final fragment
          in PaymentRuntimeBoundaryRegistry.forbiddenRuntimeImportFragments) {
        if (uri.contains(fragment)) {
          violations.add(
            PaymentRuntimeViolation(
              sourcePath: sourcePath,
              reason: 'imports:$fragment',
            ),
          );
        }
      }
    }
  }

  void _scanForbiddenSymbols({
    required String source,
    required String sourcePath,
    required List<PaymentRuntimeViolation> violations,
  }) {
    for (final symbol
        in PaymentRuntimeBoundaryRegistry.forbiddenRuntimeSymbols) {
      final pattern = RegExp('\\b${RegExp.escape(symbol)}\\b');

      if (pattern.hasMatch(source)) {
        violations.add(
          PaymentRuntimeViolation(
            sourcePath: sourcePath,
            reason: 'references:$symbol',
          ),
        );
      }
    }
  }

  String _relativeLibPath(File file) {
    final libRoot = Directory(
      '${projectRoot.path}${Platform.pathSeparator}lib',
    ).absolute.path;

    final absolutePath = file.absolute.path;

    var relative = absolutePath.substring(libRoot.length);

    while (relative.startsWith('/') || relative.startsWith('\\')) {
      relative = relative.substring(1);
    }

    return relative.replaceAll('\\', '/');
  }

  static Directory _discoverProjectRoot() {
    var current = Directory.current.absolute;

    while (true) {
      final pubspec = File('${current.path}/pubspec.yaml');

      final lib = Directory('${current.path}/lib');

      if (pubspec.existsSync() && lib.existsSync()) {
        return current;
      }

      final parent = current.parent;

      if (parent.path == current.path) {
        throw StateError('Unable to locate Mentora project root.');
      }

      current = parent;
    }
  }
}
