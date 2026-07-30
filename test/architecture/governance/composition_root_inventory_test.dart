import 'package:flutter_test/flutter_test.dart';

import 'composition_root_scanner.dart';

void main() {
  test('inventory current production composition operations', () {
    final scanner = CompositionRootScanner();
    final findings = scanner.scan();

    // ignore: avoid_print
    print('=== COMPOSITION ROOT FINDINGS ===');

    for (final finding in findings) {
      // ignore: avoid_print
      print(finding.occurrence);
    }

    final fingerprints =
        findings.map((finding) => finding.fingerprint).toSet().toList()..sort();

    // ignore: avoid_print
    print('TOTAL_COMPOSITION_OCCURRENCES=${findings.length}');

    // ignore: avoid_print
    print('TOTAL_COMPOSITION_FINGERPRINTS=${fingerprints.length}');

    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('=== BASELINE CODE START ===');
    // ignore: avoid_print
    print(
      'abstract final class '
      'CompositionRootLegacyBaseline {',
    );
    // ignore: avoid_print
    print('  static const Set<String> violations = {');

    for (final fingerprint in fingerprints) {
      // ignore: avoid_print
      print("    '$fingerprint',");
    }

    // ignore: avoid_print
    print('  };');
    // ignore: avoid_print
    print('}');
    // ignore: avoid_print
    print('=== BASELINE CODE END ===');

    expect(findings, isNotNull);
  });
}
