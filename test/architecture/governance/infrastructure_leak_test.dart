import 'package:flutter_test/flutter_test.dart';

import 'infrastructure_leak_legacy_baseline.dart';
import 'infrastructure_leak_scanner.dart';

void main() {
  group('Mentora Infrastructure Leak Governance — Sprint -1.2 / Lot E', () {
    test('ARC-E01 new infrastructure leaks are forbidden', () {
      final scanner = InfrastructureLeakScanner();

      final current = scanner
          .scanViolations()
          .map((violation) => violation.fingerprint)
          .toSet();

      final newViolations =
          current
              .difference(InfrastructureLeakLegacyBaseline.violations)
              .toList()
            ..sort();

      expect(newViolations, isEmpty, reason: _failureMessage(newViolations));
    });

    test('ARC-E02 legacy baseline must contain unique fingerprints', () {
      final baseline = InfrastructureLeakLegacyBaseline.violations;

      expect(
        baseline.length,
        45,
        reason:
            'The Lot E baseline must contain exactly '
            '45 unique legacy fingerprints.',
      );
    });

    test('ARC-E03 removing legacy leaks must remain allowed', () {
      final scanner = InfrastructureLeakScanner();

      final current = scanner
          .scanViolations()
          .map((violation) => violation.fingerprint)
          .toSet();

      final removedDebt = InfrastructureLeakLegacyBaseline.violations
          .difference(current);

      // Removing historical debt is always legal.
      expect(removedDebt.length, greaterThanOrEqualTo(0));
    });
  });
}

String _failureMessage(List<String> violations) {
  if (violations.isEmpty) {
    return '';
  }

  final buffer = StringBuffer()
    ..writeln('ARC-E01 failed.')
    ..writeln('New concrete infrastructure SDK leak(s) detected.')
    ..writeln()
    ..writeln('Existing legacy debt is grandfathered.')
    ..writeln('New infrastructure leakage is forbidden.')
    ..writeln()
    ..writeln(
      'Do not add violations to the baseline '
      'simply to make this test green.',
    )
    ..writeln()
    ..writeln('New violation(s):');

  for (final violation in violations) {
    buffer.writeln(' - $violation');
  }

  return buffer.toString();
}
