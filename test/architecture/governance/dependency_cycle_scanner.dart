import 'dart:io';

import 'dependency_direction_matrix.dart';
import 'domain_ownership_registry.dart';

/// Detects cycles in:
///
/// 1. the approved Mentora dependency policy;
/// 2. the actual import graph between registered domains.
///
/// Legacy modules such as Phoenix, Workflow and Escrow are intentionally
/// outside this ownership-level scanner.
final class DomainDependencyCycleScanner {
  DomainDependencyCycleScanner({Directory? projectRoot})
    : projectRoot = projectRoot ?? _discoverProjectRoot();

  final Directory projectRoot;

  Set<String> policyCycleSignatures() {
    final graph = <MentoraDomain, Set<MentoraDomain>>{
      for (final domain in MentoraDomain.values)
        domain: <MentoraDomain>{
          ...DependencyDirectionMatrix.allowedTargetsFor(domain),
        },
    };

    return _cycleSignatures(graph);
  }

  Set<String> actualCycleSignatures() {
    final graph = <MentoraDomain, Set<MentoraDomain>>{
      for (final ownership in domainOwnershipRegistry)
        ownership.domain: <MentoraDomain>{},
    };

    final libDirectory = Directory('${projectRoot.path}/lib');

    final files = libDirectory
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    final importPattern = RegExp("import\\s+['\"]([^'\"]+)['\"]");

    for (final sourceFile in files) {
      final sourcePath = _relativePath(sourceFile);
      final sourceDomain = _domainForPath(sourcePath);

      if (sourceDomain == null) {
        continue;
      }

      final source = sourceFile.readAsStringSync();

      for (final match in importPattern.allMatches(source)) {
        final uri = match.group(1)!;

        final targetFile = _resolveImport(sourceFile, uri);

        if (targetFile == null || !targetFile.existsSync()) {
          continue;
        }

        final targetPath = _relativePath(targetFile);
        final targetDomain = _domainForPath(targetPath);

        if (targetDomain == null || targetDomain == sourceDomain) {
          continue;
        }

        graph[sourceDomain]!.add(targetDomain);
      }
    }

    return _cycleSignatures(graph);
  }

  Set<String> _cycleSignatures(Map<MentoraDomain, Set<MentoraDomain>> graph) {
    return _stronglyConnectedComponents(
      graph,
    ).where((component) => component.length > 1).map((component) {
      final names = component.map((domain) => domain.name).toList()..sort();

      return names.join('|');
    }).toSet();
  }

  List<Set<MentoraDomain>> _stronglyConnectedComponents(
    Map<MentoraDomain, Set<MentoraDomain>> graph,
  ) {
    var nextIndex = 0;

    final index = <MentoraDomain, int>{};
    final lowLink = <MentoraDomain, int>{};

    final stack = <MentoraDomain>[];
    final onStack = <MentoraDomain>{};

    final components = <Set<MentoraDomain>>[];

    void visit(MentoraDomain node) {
      index[node] = nextIndex;
      lowLink[node] = nextIndex;

      nextIndex += 1;

      stack.add(node);
      onStack.add(node);

      final targets = graph[node] ?? const <MentoraDomain>{};

      for (final target in targets) {
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

      final component = <MentoraDomain>{};

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

    final nodes = <MentoraDomain>{
      ...graph.keys,
      ...graph.values.expand((targets) => targets),
    }.toList()..sort((a, b) => a.name.compareTo(b.name));

    for (final node in nodes) {
      if (!index.containsKey(node)) {
        visit(node);
      }
    }

    return components;
  }

  MentoraDomain? _domainForPath(String path) {
    for (final ownership in domainOwnershipRegistry) {
      if (path.startsWith('lib/core/${ownership.root}/')) {
        return ownership.domain;
      }
    }

    return null;
  }

  String _relativePath(File file) {
    final root = projectRoot.absolute.path.replaceAll('\\', '/');

    final path = file.absolute.path.replaceAll('\\', '/');

    if (!path.startsWith('$root/')) {
      throw ArgumentError('File is outside project root: ${file.path}');
    }

    return path.substring(root.length + 1);
  }

  File? _resolveImport(File sourceFile, String uri) {
    if (uri.startsWith('dart:')) {
      return null;
    }

    if (uri.startsWith('package:')) {
      const prefix = 'package:mentora/';

      if (!uri.startsWith(prefix)) {
        return null;
      }

      return File(
        '${projectRoot.path}/lib/'
        '${uri.substring(prefix.length)}',
      );
    }

    return File.fromUri(sourceFile.parent.uri.resolve(uri));
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
        throw StateError(
          'Unable to locate Mentora project root '
          'from ${Directory.current.path}.',
        );
      }

      current = parent;
    }
  }

  int _min(int a, int b) {
    return a < b ? a : b;
  }
}
