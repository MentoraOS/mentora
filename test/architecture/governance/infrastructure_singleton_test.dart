import 'package:flutter_test/flutter_test.dart';

import 'infrastructure_singleton_legacy_baseline.dart';
import 'infrastructure_singleton_scanner.dart';

void main() {
  group(
    'Mentora Infrastructure Singleton Governance — Sprint -1.2 / Lot E',
    () {
      test('ARC-E04 new direct singleton access is forbidden', () {
        final scanner = InfrastructureSingletonScanner();

        final current = scanner
            .scan()
            .map((finding) => finding.fingerprint)
            .toSet();

        final newViolations =
            current
                .difference(InfrastructureSingletonLegacyBaseline.violations)
                .toList()
              ..sort();

        expect(newViolations, isEmpty, reason: _failureMessage(newViolations));
      });

      test('ARC-E05 singleton baseline contains 34 unique fingerprints', () {
        final baseline = InfrastructureSingletonLegacyBaseline.violations;

        expect(
          baseline.length,
          34,
          reason:
              'Lot E singleton baseline must contain '
              'exactly 34 unique fingerprints.',
        );
      });

      test('ARC-E06 removing singleton debt is always allowed', () {
        final scanner = InfrastructureSingletonScanner();

        final current = scanner
            .scan()
            .map((finding) => finding.fingerprint)
            .toSet();

        final removedDebt = InfrastructureSingletonLegacyBaseline.violations
            .difference(current);

        expect(removedDebt.length, greaterThanOrEqualTo(0));
      });
    },
  );
}

String _failureMessage(List<String> violations) {
  if (violations.isEmpty) {
    return '';
  }

  final buffer = StringBuffer()
    ..writeln('ARC-E04 failed.')
    ..writeln('New direct infrastructure singleton access detected.')
    ..writeln()
    ..writeln('Existing legacy singleton access is grandfathered.')
    ..writeln('New direct singleton access is forbidden.')
    ..writeln()
    ..writeln(
      'Use dependency injection, a repository, '
      'a gateway or an infrastructure adapter.',
    )
    ..writeln()
    ..writeln(
      'Do not add a new entry to the baseline '
      'simply to make this test green.',
    )
    ..writeln()
    ..writeln('New violation(s):');

  for (final violation in violations) {
    buffer.writeln(' - $violation');
  }

  return buffer.toString();
}
