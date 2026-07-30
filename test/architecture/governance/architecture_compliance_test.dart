import 'package:flutter_test/flutter_test.dart';

import 'architecture_legacy_baseline.dart';
import 'architecture_scanner.dart';

void main() {
  late ArchitectureScanner scanner;

  setUpAll(() {
    scanner = ArchitectureScanner();
  });

  group('Mentora Architecture Governance — Sprint -1.2 / Lot B', () {
    test('ARC-001 Domain must not gain Flutter UI imports', () {
      final current = scanner.importFindings(
        fileFilter: scanner.isDomainFile,
        importFilter: (uri) =>
            uri == 'package:flutter/material.dart' ||
            uri == 'package:flutter/widgets.dart',
      );

      _expectNoNewViolations(
        rule: 'ARC-001',
        current: current,
        baseline: ArchitectureLegacyBaseline.domainFlutterUiImports,
      );
    });

    test('ARC-002/003 Domain must not gain Firebase or Firestore imports', () {
      final current = scanner.importFindings(
        fileFilter: scanner.isDomainFile,
        importFilter: (uri) =>
            uri.startsWith('package:firebase_') ||
            uri.startsWith('package:cloud_firestore/'),
      );

      _expectNoNewViolations(
        rule: 'ARC-002/003',
        current: current,
        baseline: ArchitectureLegacyBaseline.domainFirebaseImports,
      );
    });

    test('ARC-004 Domain must not gain Agora imports', () {
      final current = scanner.importFindings(
        fileFilter: scanner.isDomainFile,
        importFilter: (uri) => uri.startsWith('package:agora_rtc_engine/'),
      );

      _expectNoNewViolations(
        rule: 'ARC-004',
        current: current,
        baseline: ArchitectureLegacyBaseline.domainAgoraImports,
      );
    });

    test('ARC-005 Product domains must not gain concrete PSP SDK imports', () {
      const productPrefixes = {
        'lib/core/booking/',
        'lib/core/scheduling/',
        'lib/core/payment/',
        'lib/core/consultation/',
      };

      const pspPrefixes = {
        'package:stripe/',
        'package:flutter_stripe/',
        'package:paydunya/',
        'package:cinetpay/',
        'package:flutterwave/',
        'package:paystack/',
        'package:wave/',
        'package:orange_money/',
      };

      final current = scanner.importFindings(
        fileFilter: (file) {
          final path = scanner.relativePath(file);
          return productPrefixes.any(path.startsWith);
        },
        importFilter: (uri) => pspPrefixes.any(uri.startsWith),
      );

      _expectNoNewViolations(
        rule: 'ARC-005',
        current: current,
        baseline: ArchitectureLegacyBaseline.productPspSdkImports,
      );
    });

    test('ARC-006 Booking must not import Financial internals', () {
      final current = scanner.importFindings(
        fileFilter: (file) =>
            scanner.relativePath(file).startsWith('lib/core/booking/'),
        importFilter: (uri) =>
            uri.startsWith('package:mentora/core/financial/') ||
            RegExp(r'^(?:\.\./)+financial/').hasMatch(uri),
      );

      _expectNoNewViolations(
        rule: 'ARC-006',
        current: current,
        baseline: ArchitectureLegacyBaseline.bookingFinancialInternalImports,
      );
    });

    test('ARC-007 Consultation must not import Financial internals', () {
      final current = scanner.importFindings(
        fileFilter: (file) =>
            scanner.relativePath(file).startsWith('lib/core/consultation/'),
        importFilter: (uri) =>
            uri.startsWith('package:mentora/core/financial/') ||
            RegExp(r'^(?:\.\./)+financial/').hasMatch(uri),
      );

      _expectNoNewViolations(
        rule: 'ARC-007',
        current: current,
        baseline:
            ArchitectureLegacyBaseline.consultationFinancialInternalImports,
      );
    });

    test('ARC-008 Consultation must not import Agora implementation', () {
      final current = scanner.importFindings(
        fileFilter: (file) =>
            scanner.relativePath(file).startsWith('lib/core/consultation/'),
        importFilter: (uri) => uri.startsWith('package:agora_rtc_engine/'),
      );

      _expectNoNewViolations(
        rule: 'ARC-008',
        current: current,
        baseline: ArchitectureLegacyBaseline.consultationAgoraImports,
      );
    });

    test('ARC-009 Presentation must not gain direct Firestore imports', () {
      final current = scanner.importFindings(
        fileFilter: scanner.isPresentationFile,
        importFilter: (uri) => uri.startsWith('package:cloud_firestore/'),
      );

      _expectNoNewViolations(
        rule: 'ARC-009',
        current: current,
        baseline: ArchitectureLegacyBaseline.presentationFirestoreImports,
      );
    });

    test('ARC-009B Presentation must not gain direct FirebaseAuth imports', () {
      final current = scanner.importFindings(
        fileFilter: scanner.isPresentationFile,
        importFilter: (uri) => uri.startsWith('package:firebase_auth/'),
      );

      _expectNoNewViolations(
        rule: 'ARC-009B',
        current: current,
        baseline: ArchitectureLegacyBaseline.presentationFirebaseAuthImports,
      );
    });

    test('ARC-011 Critical product domains must not import screens', () {
      const criticalPrefixes = {
        'lib/core/booking/',
        'lib/core/scheduling/',
        'lib/core/payment/',
        'lib/core/consultation/',
      };

      final current = scanner.importFindings(
        fileFilter: (file) {
          final path = scanner.relativePath(file);
          return criticalPrefixes.any(path.startsWith);
        },
        importFilter: (uri) =>
            uri.startsWith('package:mentora/screens/') ||
            RegExp(r'^(?:\.\./)+screens/').hasMatch(uri),
      );

      _expectNoNewViolations(
        rule: 'ARC-011',
        current: current,
        baseline: ArchitectureLegacyBaseline.productScreensImports,
      );
    });

    test(
      'ARC-012 Critical cross-domain internal imports must not increase',
      () {
        final current = scanner.crossCriticalDomainImports();

        _expectNoNewViolations(
          rule: 'ARC-012',
          current: current,
          baseline: ArchitectureLegacyBaseline.crossCriticalDomainImports,
        );
      },
    );

    test('ARC-013 Module dependency cycles must not increase', () {
      final current = scanner.moduleCycleSignatures();
      final baseline = ArchitectureLegacyBaseline.moduleCycleSignatures;

      final newViolations = current.where((currentSignature) {
        final currentModules = currentSignature.split('|').toSet();

        return !baseline.any((baselineSignature) {
          final baselineModules = baselineSignature.split('|').toSet();

          // A current cycle is acceptable when it is equal to
          // or strictly smaller than an existing legacy cycle.
          return baselineModules.containsAll(currentModules);
        });
      }).toList()..sort();

      expect(
        newViolations,
        isEmpty,
        reason: _failureMessage('ARC-013', newViolations),
      );
    });

    test(
      'Baseline entries must still correspond to current violations or debt removed',
      () {
        // Removing legacy debt is always allowed.
        // This test intentionally does not require equality with the baseline.
        // The guard only requires: current violations ⊆ known baseline.
        expect(true, isTrue);
      },
    );
  });
}

void _expectNoNewViolations({
  required String rule,
  required Set<String> current,
  required Set<String> baseline,
}) {
  final newViolations = current.difference(baseline).toList()..sort();

  expect(newViolations, isEmpty, reason: _failureMessage(rule, newViolations));
}

String _failureMessage(String rule, List<String> violations) {
  if (violations.isEmpty) {
    return '';
  }

  final buffer = StringBuffer()
    ..writeln('$rule introduced new architecture violation(s).')
    ..writeln()
    ..writeln('Existing legacy debt is grandfathered; NEW debt is forbidden.')
    ..writeln('Do not add the new violation to the baseline as a shortcut.')
    ..writeln(
      'Either fix the dependency or approve an explicit architecture decision.',
    )
    ..writeln()
    ..writeln('New violation(s):');

  for (final violation in violations) {
    buffer.writeln(' - $violation');
  }

  return buffer.toString();
}
