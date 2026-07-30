import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'runtime_placeholder_scanner.dart';

void main() {
  test('inventory current runtime placeholders', () {
    final scanner = RuntimePlaceholderScanner();

    final findings = scanner.scan();

    final unique = scanner.uniqueFingerprints().toList()..sort();

    debugPrint('=== RUNTIME PLACEHOLDER FINDINGS ===');

    for (final finding in findings) {
      debugPrint(finding.toString());
    }

    debugPrint(
      'TOTAL_RUNTIME_PLACEHOLDER_OCCURRENCES='
      '${findings.length}',
    );

    debugPrint(
      'TOTAL_RUNTIME_PLACEHOLDER_FINGERPRINTS='
      '${unique.length}',
    );

    debugPrint('');
    debugPrint('=== BASELINE CODE START ===');

    debugPrint(
      'abstract final class '
      'RuntimePlaceholderLegacyBaseline {',
    );

    debugPrint('  static const bool initialized = true;');

    debugPrint('');

    debugPrint('  static const Set<String> violations = {');

    for (final fingerprint in unique) {
      debugPrint("    '$fingerprint',");
    }

    debugPrint('  };');
    debugPrint('}');

    debugPrint('=== BASELINE CODE END ===');
  });
}
