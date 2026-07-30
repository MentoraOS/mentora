import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'infrastructure_singleton_scanner.dart';

void main() {
  test('inventory current infrastructure singleton access', () {
    final scanner = InfrastructureSingletonScanner();

    final findings = scanner.scan();

    for (final finding in findings) {
      debugPrint(finding.fingerprint);
    }

    final uniqueFingerprints = findings
        .map((finding) => finding.fingerprint)
        .toSet();

    debugPrint('TOTAL_INFRASTRUCTURE_SINGLETON_OCCURRENCES=${findings.length}');

    debugPrint('TOTAL_INFRASTRUCTURE_SINGLETONS=${uniqueFingerprints.length}');
  });
}
