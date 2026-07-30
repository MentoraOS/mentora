import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'infrastructure_leak_scanner.dart';

void main() {
  test('inventory current infrastructure leaks', () {
    final scanner = InfrastructureLeakScanner();

    final violations = scanner.scanViolations();

    for (final violation in violations) {
      debugPrint(violation.fingerprint);
    }

    final uniqueFingerprints = violations
        .map((violation) => violation.fingerprint)
        .toSet();

    debugPrint('TOTAL_INFRASTRUCTURE_LEAK_OCCURRENCES=${violations.length}');

    debugPrint('TOTAL_INFRASTRUCTURE_LEAKS=${uniqueFingerprints.length}');
  });
}
