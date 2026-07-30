import 'package:flutter_test/flutter_test.dart';

import 'runtime_placeholder_legacy_baseline.dart';
import 'runtime_placeholder_scanner.dart';

void main() {
  group('Mentora Runtime Placeholder Governance — '
      'Sprint -1.2 / Lot E.4', () {
    test('ARC-E07 runtime placeholder baseline '
        'must be initialized', () {
      expect(
        RuntimePlaceholderLegacyBaseline.initialized,
        isTrue,
        reason:
            'Runtime placeholder baseline is '
            'not initialized. Run '
            'runtime_placeholder_inventory_test.dart '
            'and paste the generated baseline.',
      );
    });

    test('ARC-E08 new runtime placeholders '
        'are forbidden', () {
      _requireInitialized();

      final scanner = RuntimePlaceholderScanner();

      final current = scanner.uniqueFingerprints();

      final newViolations =
          current
              .difference(RuntimePlaceholderLegacyBaseline.violations)
              .toList()
            ..sort();

      expect(newViolations, isEmpty, reason: _failureMessage(newViolations));
    });

    test('ARC-E09 baseline contains unique '
        'fingerprints', () {
      _requireInitialized();

      final baseline = RuntimePlaceholderLegacyBaseline.violations;

      expect(baseline.length, baseline.toSet().length);
    });

    test('ARC-E10 removing runtime debt '
        'is always allowed', () {
      _requireInitialized();

      final scanner = RuntimePlaceholderScanner();

      final current = scanner.uniqueFingerprints();

      final removedDebt = RuntimePlaceholderLegacyBaseline.violations
          .difference(current);

      expect(removedDebt.length, greaterThanOrEqualTo(0));
    });
  });
}

void _requireInitialized() {
  if (!RuntimePlaceholderLegacyBaseline.initialized) {
    fail(
      'RuntimePlaceholderLegacyBaseline '
      'is not initialized. '
      'Run the inventory test first.',
    );
  }
}

String _failureMessage(List<String> violations) {
  if (violations.isEmpty) {
    return '';
  }

  final buffer = StringBuffer()
    ..writeln('ARC-E08 failed.')
    ..writeln('New runtime placeholder(s) detected.')
    ..writeln()
    ..writeln('Existing runtime debt is grandfathered.')
    ..writeln('New placeholders are forbidden.')
    ..writeln()
    ..writeln(
      'Do not add a new fingerprint to '
      'the baseline simply to make the '
      'test green.',
    )
    ..writeln()
    ..writeln('New violation(s):');

  for (final violation in violations) {
    buffer.writeln(' - $violation');
  }

  return buffer.toString();
}
