import 'dart:io';

enum InfrastructureSingleton { firebaseFirestore, firebaseAuth }

final class SingletonAccess {
  const SingletonAccess({
    required this.sourcePath,
    required this.singleton,
    required this.pattern,
  });

  final String sourcePath;
  final InfrastructureSingleton singleton;
  final String pattern;

  String get fingerprint => '${singleton.name}|$sourcePath|$pattern';

  @override
  String toString() => fingerprint;
}

final class InfrastructureSingletonScanner {
  InfrastructureSingletonScanner({Directory? projectRoot})
    : projectRoot = projectRoot ?? Directory.current;

  final Directory projectRoot;

  List<SingletonAccess> scan() {
    final libDirectory = Directory(
      '${projectRoot.path}${Platform.pathSeparator}lib',
    );

    if (!libDirectory.existsSync()) {
      throw StateError(
        'Unable to scan singleton access: '
        'lib/ was not found at ${libDirectory.path}.',
      );
    }

    final findings = <SingletonAccess>[];

    for (final entity in libDirectory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final content = entity.readAsStringSync();
      final sourcePath = _relativeLibPath(entity);

      if (_isAllowedCompositionRoot(sourcePath)) {
        continue;
      }

      _collect(
        findings: findings,
        content: content,
        sourcePath: sourcePath,
        singleton: InfrastructureSingleton.firebaseFirestore,
        pattern: 'FirebaseFirestore.instance',
      );

      _collect(
        findings: findings,
        content: content,
        sourcePath: sourcePath,
        singleton: InfrastructureSingleton.firebaseAuth,
        pattern: 'FirebaseAuth.instance',
      );
    }

    findings.sort((a, b) => a.fingerprint.compareTo(b.fingerprint));

    return List.unmodifiable(findings);
  }

  bool _isAllowedCompositionRoot(String sourcePath) {
    return sourcePath == 'infrastructure/firebase/firebase_dependencies.dart';
  }

  void _collect({
    required List<SingletonAccess> findings,
    required String content,
    required String sourcePath,
    required InfrastructureSingleton singleton,
    required String pattern,
  }) {
    if (content.contains(pattern)) {
      findings.add(
        SingletonAccess(
          sourcePath: sourcePath,
          singleton: singleton,
          pattern: pattern,
        ),
      );
    }
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
}
