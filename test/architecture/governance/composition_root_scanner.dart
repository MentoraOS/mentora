import 'dart:io';

import 'composition_root_registry.dart';

enum CompositionOperation {
  firebaseInitialization,
  firebaseProductionDependencies,
  firebaseAuthenticationAdapter,
  firebaseSessionAdapter,
  firebaseWorkspaceAdapter,
  firebaseWorkspaceMemberAdapter,
}

final class CompositionFinding {
  const CompositionFinding({
    required this.sourcePath,
    required this.operation,
    required this.pattern,
    required this.lineNumber,
  });

  final String sourcePath;
  final CompositionOperation operation;
  final String pattern;
  final int lineNumber;

  /// Stable fingerprint intentionally excludes the line number.
  ///
  /// Moving legacy code inside the same file must not create artificial
  /// baseline churn.
  String get fingerprint => '${operation.name}|$sourcePath|$pattern';

  String get occurrence =>
      '${operation.name}|$sourcePath|line=$lineNumber|$pattern';

  @override
  String toString() => occurrence;
}

final class CompositionRootScanner {
  CompositionRootScanner({Directory? projectRoot})
    : projectRoot = projectRoot ?? Directory.current;

  final Directory projectRoot;

  List<CompositionFinding> scan() {
    final libDirectory = Directory(
      '${projectRoot.path}${Platform.pathSeparator}lib',
    );

    if (!libDirectory.existsSync()) {
      throw StateError(
        'Unable to scan composition roots: '
        'lib/ was not found at ${libDirectory.path}.',
      );
    }

    final findings = <CompositionFinding>[];

    for (final entity in libDirectory.listSync(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final sourcePath = _relativeLibPath(entity);

      // Official composition boundaries are intentionally excluded.
      if (CompositionRootRegistry.isAllowedCompositionBoundary(sourcePath)) {
        continue;
      }

      final lines = entity.readAsLinesSync();
      final classScope = _ClassScopeTracker();

      for (var index = 0; index < lines.length; index++) {
        final line = lines[index];
        final lineNumber = index + 1;

        classScope.beginLine();

        final trimmedLine = line.trimLeft();

        if (trimmedLine.startsWith('//') ||
            trimmedLine.startsWith('///') ||
            trimmedLine.startsWith('*')) {
          classScope.consume(line);
          continue;
        }

        _collect(
          findings: findings,
          sourcePath: sourcePath,
          line: line,
          lineNumber: lineNumber,
          operation: CompositionOperation.firebaseInitialization,
          pattern: 'Firebase.initializeApp(',
          regex: RegExp(r'\bFirebase\.initializeApp\s*\('),
        );

        _collect(
          findings: findings,
          sourcePath: sourcePath,
          line: line,
          lineNumber: lineNumber,
          operation: CompositionOperation.firebaseProductionDependencies,
          pattern: 'FirebaseDependencies.production(',
          regex: RegExp(r'\bFirebaseDependencies\.production\s*\('),
        );

        _collectConstructorInvocation(
          findings: findings,
          sourcePath: sourcePath,
          line: line,
          lineNumber: lineNumber,
          operation: CompositionOperation.firebaseAuthenticationAdapter,
          constructorName: 'FirebaseAuthenticationService',
          pattern: 'FirebaseAuthenticationService(',
          classScope: classScope,
        );

        _collectConstructorInvocation(
          findings: findings,
          sourcePath: sourcePath,
          line: line,
          lineNumber: lineNumber,
          operation: CompositionOperation.firebaseSessionAdapter,
          constructorName: 'FirebaseSessionRepository',
          pattern: 'FirebaseSessionRepository(',
          classScope: classScope,
        );

        _collectConstructorInvocation(
          findings: findings,
          sourcePath: sourcePath,
          line: line,
          lineNumber: lineNumber,
          operation: CompositionOperation.firebaseWorkspaceAdapter,
          constructorName: 'FirebaseWorkspaceRepository',
          pattern: 'FirebaseWorkspaceRepository(',
          classScope: classScope,
        );

        _collectConstructorInvocation(
          findings: findings,
          sourcePath: sourcePath,
          line: line,
          lineNumber: lineNumber,
          operation: CompositionOperation.firebaseWorkspaceMemberAdapter,
          constructorName: 'FirebaseWorkspaceMemberRepository',
          pattern: 'FirebaseWorkspaceMemberRepository(',
          classScope: classScope,
        );

        classScope.consume(line);
      }
    }

    findings.sort((a, b) => a.occurrence.compareTo(b.occurrence));

    return List.unmodifiable(findings);
  }

  void _collect({
    required List<CompositionFinding> findings,
    required String sourcePath,
    required String line,
    required int lineNumber,
    required CompositionOperation operation,
    required String pattern,
    required RegExp regex,
  }) {
    if (!regex.hasMatch(line)) {
      return;
    }

    findings.add(
      CompositionFinding(
        sourcePath: sourcePath,
        operation: operation,
        pattern: pattern,
        lineNumber: lineNumber,
      ),
    );
  }

  void _collectConstructorInvocation({
    required List<CompositionFinding> findings,
    required String sourcePath,
    required String line,
    required int lineNumber,
    required CompositionOperation operation,
    required String constructorName,
    required String pattern,
    required _ClassScopeTracker classScope,
  }) {
    final constructorPattern = RegExp(
      '\\b${RegExp.escape(constructorName)}\\s*\\(',
    );

    if (!constructorPattern.hasMatch(line) ||
        classScope.isConstructorDeclaration(
          line: line,
          constructorName: constructorName,
        )) {
      return;
    }

    findings.add(
      CompositionFinding(
        sourcePath: sourcePath,
        operation: operation,
        pattern: pattern,
        lineNumber: lineNumber,
      ),
    );
  }

  String _relativeLibPath(File file) {
    final libRoot = Directory(
      '${projectRoot.path}${Platform.pathSeparator}lib',
    ).absolute.path;

    final absoluteFilePath = file.absolute.path;

    if (!absoluteFilePath.startsWith(libRoot)) {
      throw ArgumentError('File is outside lib/: ${file.path}');
    }

    var relativePath = absoluteFilePath.substring(libRoot.length);

    while (relativePath.startsWith('/') || relativePath.startsWith('\\')) {
      relativePath = relativePath.substring(1);
    }

    return relativePath.replaceAll('\\', '/');
  }
}

final class _ClassScope {
  const _ClassScope({required this.name, required this.bodyDepth});

  final String name;
  final int bodyDepth;
}

final class _ClassScopeTracker {
  static final RegExp _classDeclaration = RegExp(r'\bclass\s+([A-Za-z_]\w*)');

  final List<_ClassScope> _scopes = [];

  int _braceDepth = 0;
  String? _pendingClassName;

  void beginLine() {
    while (_scopes.isNotEmpty && _braceDepth < _scopes.last.bodyDepth) {
      _scopes.removeLast();
    }
  }

  bool isConstructorDeclaration({
    required String line,
    required String constructorName,
  }) {
    if (_scopes.isEmpty ||
        _scopes.last.name != constructorName ||
        _braceDepth != _scopes.last.bodyDepth) {
      return false;
    }

    final declarationPattern = RegExp(
      '^\\s*(?:(?:const|factory|external)\\s+)?'
      '${RegExp.escape(constructorName)}'
      r'(?:\.[A-Za-z_]\w*)?\s*\(',
    );

    return declarationPattern.hasMatch(line);
  }

  void consume(String line) {
    final code = _withoutLineComment(line);
    final classMatch = _classDeclaration.firstMatch(code);

    if (classMatch != null) {
      _pendingClassName = classMatch.group(1);
    }

    for (final codeUnit in code.codeUnits) {
      if (codeUnit == 123) {
        _braceDepth += 1;

        final pendingClassName = _pendingClassName;

        if (pendingClassName != null) {
          _scopes.add(
            _ClassScope(name: pendingClassName, bodyDepth: _braceDepth),
          );
          _pendingClassName = null;
        }
      } else if (codeUnit == 125) {
        _braceDepth -= 1;
      }
    }
  }

  String _withoutLineComment(String line) {
    final commentStart = line.indexOf('//');

    if (commentStart < 0) {
      return line;
    }

    return line.substring(0, commentStart);
  }
}
