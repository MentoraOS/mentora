import 'dart:io';

final class ArchitectureFinding {
  const ArchitectureFinding({required this.file, required this.detail});

  final String file;
  final String detail;

  String get key => detail.isEmpty ? file : '$file|$detail';

  @override
  String toString() => detail.isEmpty ? file : '$file -> $detail';
}

final class ArchitectureScanner {
  ArchitectureScanner({Directory? projectRoot})
    : projectRoot = projectRoot ?? _discoverProjectRoot();

  final Directory projectRoot;

  Directory get libDirectory => Directory('${projectRoot.path}/lib');

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
        throw StateError(
          'Unable to locate Mentora project root from ${Directory.current.path}.',
        );
      }

      current = parent;
    }
  }

  List<File> get dartFiles {
    if (!libDirectory.existsSync()) {
      throw StateError('Missing lib directory: ${libDirectory.path}');
    }

    final files =
        libDirectory
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    return files;
  }

  String relativePath(File file) {
    final root = projectRoot.absolute.path.replaceAll(r'\', '/');
    final path = file.absolute.path.replaceAll(r'\', '/');

    if (!path.startsWith('$root/')) {
      throw ArgumentError('File is outside project root: ${file.path}');
    }

    return path.substring(root.length + 1);
  }

  String read(File file) => file.readAsStringSync();

  List<String> importsOf(File file) {
    final regex = RegExp(r'''import\s+['"]([^'"]+)['"]''');
    return regex
        .allMatches(read(file))
        .map((match) => match.group(1)!)
        .toList(growable: false);
  }

  bool isDomainFile(File file) {
    final segments = relativePath(file).split('/');
    return segments.contains('domain') || segments.contains('domains');
  }

  bool isPresentationFile(File file) {
    final segments = relativePath(file).split('/');

    if (segments.length > 1 &&
        {'screens', 'presentation', 'widgets'}.contains(segments[1])) {
      return true;
    }

    return segments.contains('presentation') ||
        segments.contains('screens') ||
        segments.contains('pages') ||
        segments.contains('views');
  }

  Set<String> filesMatching({
    required bool Function(File file) fileFilter,
    required bool Function(String source) sourceFilter,
  }) {
    final findings = <String>{};

    for (final file in dartFiles) {
      if (!fileFilter(file)) {
        continue;
      }

      if (sourceFilter(read(file))) {
        findings.add(relativePath(file));
      }
    }

    return findings;
  }

  Set<String> importFindings({
    required bool Function(File file) fileFilter,
    required bool Function(String importUri) importFilter,
  }) {
    final findings = <String>{};

    for (final file in dartFiles) {
      if (!fileFilter(file)) {
        continue;
      }

      for (final importUri in importsOf(file)) {
        if (importFilter(importUri)) {
          findings.add(relativePath(file));
        }
      }
    }

    return findings;
  }

  Set<String> crossCriticalDomainImports() {
    const domains = {
      'booking',
      'scheduling',
      'payment',
      'consultation',
      'financial',
      'meeting',
      'identity',
      'notification',
    };

    final findings = <String>{};

    for (final file in dartFiles) {
      final sourceDomain = _criticalDomainFor(relativePath(file), domains);
      if (sourceDomain == null) {
        continue;
      }

      for (final importUri in importsOf(file)) {
        for (final targetDomain in domains) {
          if (targetDomain == sourceDomain) {
            continue;
          }

          if (_importsCoreDomain(importUri, targetDomain)) {
            findings.add('${relativePath(file)}|$importUri');
          }
        }
      }
    }

    return findings;
  }

  Set<String> moduleCycleSignatures() {
    final graph = <String, Set<String>>{};

    for (final file in dartFiles) {
      final sourceModule = _moduleFor(file);

      for (final importUri in importsOf(file)) {
        final target = _resolveLocalImport(file, importUri);
        if (target == null || !target.existsSync()) {
          continue;
        }

        final targetModule = _moduleFor(target);
        if (sourceModule == targetModule) {
          continue;
        }

        graph.putIfAbsent(sourceModule, () => <String>{}).add(targetModule);
        graph.putIfAbsent(targetModule, () => <String>{});
      }
    }

    return _stronglyConnectedComponents(
      graph,
    ).where((component) => component.length > 1).map((component) {
      final sorted = component.toList()..sort();
      return sorted.join('|');
    }).toSet();
  }

  String? _criticalDomainFor(String path, Set<String> domains) {
    for (final domain in domains) {
      if (path.startsWith('lib/core/$domain/')) {
        return domain;
      }
    }

    return null;
  }

  bool _importsCoreDomain(String uri, String domain) {
    if (uri.startsWith('package:mentora/core/$domain/')) {
      return true;
    }

    final relativeRegex = RegExp(
      r'^(?:\.\./)+'
      '${RegExp.escape(domain)}'
      r'/',
    );

    return relativeRegex.hasMatch(uri);
  }

  String _moduleFor(File file) {
    final path = relativePath(file);
    final segments = path.split('/');

    if (segments.length < 2 || segments.first != 'lib') {
      return segments.first;
    }

    if (segments[1] == 'core' && segments.length > 2) {
      return 'core/${segments[2]}';
    }

    if (segments[1] == 'features' && segments.length > 2) {
      return 'features/${segments[2]}';
    }

    if (segments[1] == 'main.dart') {
      return 'main.dart';
    }

    return segments[1];
  }

  File? _resolveLocalImport(File source, String uri) {
    if (uri.startsWith('dart:')) {
      return null;
    }

    if (uri.startsWith('package:')) {
      const prefix = 'package:mentora/';
      if (!uri.startsWith(prefix)) {
        return null;
      }

      return File('${libDirectory.path}/${uri.substring(prefix.length)}');
    }

    final normalizedSource = source.parent.uri.resolve(uri);
    return File.fromUri(normalizedSource);
  }

  List<Set<String>> _stronglyConnectedComponents(
    Map<String, Set<String>> graph,
  ) {
    var nextIndex = 0;
    final index = <String, int>{};
    final lowLink = <String, int>{};
    final stack = <String>[];
    final onStack = <String>{};
    final components = <Set<String>>[];

    void visit(String node) {
      index[node] = nextIndex;
      lowLink[node] = nextIndex;
      nextIndex += 1;
      stack.add(node);
      onStack.add(node);

      for (final target in graph[node] ?? const <String>{}) {
        if (!index.containsKey(target)) {
          visit(target);
          lowLink[node] = _min(lowLink[node]!, lowLink[target]!);
        } else if (onStack.contains(target)) {
          lowLink[node] = _min(lowLink[node]!, index[target]!);
        }
      }

      if (lowLink[node] != index[node]) {
        return;
      }

      final component = <String>{};

      while (stack.isNotEmpty) {
        final member = stack.removeLast();
        onStack.remove(member);
        component.add(member);

        if (member == node) {
          break;
        }
      }

      components.add(component);
    }

    final nodes = <String>{
      ...graph.keys,
      ...graph.values.expand((targets) => targets),
    }.toList()..sort();

    for (final node in nodes) {
      if (!index.containsKey(node)) {
        visit(node);
      }
    }

    return components;
  }

  int _min(int a, int b) => a < b ? a : b;
}
