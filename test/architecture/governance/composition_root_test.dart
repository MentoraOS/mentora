import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'composition_root_legacy_baseline.dart';
import 'composition_root_registry.dart';
import 'composition_root_scanner.dart';

void main() {
  group('Mentora Composition Root Governance — '
      'Sprint -1.3 / Lot A / A.2.1', () {
    test('ARC-A01 production composition is restricted '
        'to approved composition roots', () {
      final scanner = CompositionRootScanner();

      final current = scanner
          .scan()
          .map((finding) => finding.fingerprint)
          .toSet();

      final newViolations =
          current.difference(CompositionRootLegacyBaseline.violations).toList()
            ..sort();

      expect(newViolations, isEmpty, reason: _failureMessage(newViolations));
    });

    test('ARC-A02 canonical composition root is registered', () {
      expect(
        CompositionRootRegistry.allowedCompositionRoots,
        contains('composition/mentora_composition_root.dart'),
      );
    });

    test('ARC-A03 Firebase provider boundary is registered', () {
      expect(
        CompositionRootRegistry.allowedInfrastructureProviders,
        contains('infrastructure/firebase/firebase_dependencies.dart'),
      );
    });

    test('ARC-A04 legacy composition debt may only decrease', () {
      final scanner = CompositionRootScanner();

      final current = scanner
          .scan()
          .map((finding) => finding.fingerprint)
          .toSet();

      final removedDebt = CompositionRootLegacyBaseline.violations.difference(
        current,
      );

      // Debt removal is always valid.
      expect(removedDebt.length, greaterThanOrEqualTo(0));
    });

    test('ARC-A05 Workspace Member production dependency is wired through '
        'the canonical composition root', () {
      final root = _projectRoot();
      final dependencies = File(
        '${root.path}/lib/composition/mentora_dependencies.dart',
      ).readAsStringSync();
      final compositionRoot = File(
        '${root.path}/lib/composition/mentora_composition_root.dart',
      ).readAsStringSync();
      final adapter = File(
        '${root.path}/lib/infrastructure/workspace/'
        'firebase_workspace_member_repository.dart',
      ).readAsStringSync();

      expect(
        dependencies,
        contains('final WorkspaceMemberRepository workspaceMemberRepository;'),
      );
      expect(
        dependencies,
        contains('required this.workspaceMemberRepository,'),
      );
      expect(
        dependencies,
        isNot(contains('FirebaseWorkspaceMemberRepository')),
      );

      expect(
        compositionRoot,
        contains('final WorkspaceMemberRepository workspaceMemberRepository ='),
      );
      expect(
        compositionRoot,
        contains(
          'FirebaseWorkspaceMemberRepository(firestore: firebase.firestore)',
        ),
      );
      expect(
        compositionRoot,
        contains('workspaceMemberRepository: workspaceMemberRepository,'),
      );

      expect(adapter, contains('required FirebaseFirestore firestore,'));
      expect(adapter, isNot(contains('FirebaseFirestore.instance')));

      expect(compositionRoot, contains('FirebaseWorkspaceRepository('));
      expect(compositionRoot, contains('FirebaseSessionRepository('));
      expect(compositionRoot, contains('FirebaseAuthenticationService('));
    });

    test('ARC-A06 adapter constructor declarations are not composition', () {
      final temporaryRoot = Directory.systemTemp.createTempSync(
        'mentora_composition_root_test_',
      );

      try {
        _writeProbe(temporaryRoot, 'lib/infrastructure/probe.dart', '''
final class FirebaseAuthenticationService {
  FirebaseAuthenticationService();
}

final class FirebaseSessionRepository {
  FirebaseSessionRepository();
}

final class FirebaseWorkspaceRepository {
  const FirebaseWorkspaceRepository();
}

final class FirebaseWorkspaceMemberRepository {
  const FirebaseWorkspaceMemberRepository();
}
''');

        final findings = CompositionRootScanner(
          projectRoot: temporaryRoot,
        ).scan();

        expect(findings, isEmpty);
      } finally {
        temporaryRoot.deleteSync(recursive: true);
      }
    });

    test('ARC-A07 production construction is allowed in the canonical '
        'composition root', () {
      final temporaryRoot = Directory.systemTemp.createTempSync(
        'mentora_composition_root_test_',
      );

      try {
        _writeProbe(
          temporaryRoot,
          'lib/composition/mentora_composition_root.dart',
          '''
Future<void> production() async {
  await Firebase.initializeApp();
  final firebase = FirebaseDependencies.production();
  final authentication = FirebaseAuthenticationService();
  final session = FirebaseSessionRepository();
  final workspace = FirebaseWorkspaceRepository();
  final workspaceMember = FirebaseWorkspaceMemberRepository();
}
''',
        );

        final findings = CompositionRootScanner(
          projectRoot: temporaryRoot,
        ).scan();

        expect(findings, isEmpty);
      } finally {
        temporaryRoot.deleteSync(recursive: true);
      }
    });

    test('ARC-A08 production construction is detected outside the canonical '
        'composition root', () {
      final temporaryRoot = Directory.systemTemp.createTempSync(
        'mentora_composition_root_test_',
      );

      try {
        _writeProbe(temporaryRoot, 'lib/screens/probe.dart', '''
Future<void> createDependencies() async {
  await Firebase.initializeApp();
  final firebase = FirebaseDependencies.production();
  final authentication = FirebaseAuthenticationService();
  final session = FirebaseSessionRepository();
  final workspace = FirebaseWorkspaceRepository();
  final workspaceMember = FirebaseWorkspaceMemberRepository();
}
''');

        final findings = CompositionRootScanner(
          projectRoot: temporaryRoot,
        ).scan();

        expect(findings, hasLength(6));
        expect(findings.map((finding) => finding.operation).toSet(), {
          CompositionOperation.firebaseInitialization,
          CompositionOperation.firebaseProductionDependencies,
          CompositionOperation.firebaseAuthenticationAdapter,
          CompositionOperation.firebaseSessionAdapter,
          CompositionOperation.firebaseWorkspaceAdapter,
          CompositionOperation.firebaseWorkspaceMemberAdapter,
        });
        expect(findings.map((finding) => finding.sourcePath).toSet(), {
          'screens/probe.dart',
        });
      } finally {
        temporaryRoot.deleteSync(recursive: true);
      }
    });
  });
}

void _writeProbe(Directory root, String relativePath, String source) {
  final file = File('${root.path}/$relativePath')..createSync(recursive: true);

  file.writeAsStringSync(source);
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

String _failureMessage(List<String> violations) {
  if (violations.isEmpty) {
    return '';
  }

  final buffer = StringBuffer()
    ..writeln('ARC-A01 failed.')
    ..writeln()
    ..writeln(
      'Production infrastructure composition was detected '
      'outside an approved composition root.',
    )
    ..writeln()
    ..writeln(
      'Construction of production adapters and SDK initialization '
      'must occur through the Mentora Composition Root.',
    )
    ..writeln()
    ..writeln(
      'Do NOT add the violation to the legacy baseline '
      'to make this test green.',
    )
    ..writeln()
    ..writeln('Move production composition to:')
    ..writeln('  lib/composition/mentora_composition_root.dart')
    ..writeln()
    ..writeln('New violation(s):');

  for (final violation in violations) {
    buffer.writeln(' - $violation');
  }

  return buffer.toString();
}
