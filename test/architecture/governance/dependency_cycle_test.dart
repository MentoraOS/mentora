import 'package:flutter_test/flutter_test.dart';

import 'dependency_cycle_scanner.dart';

void main() {
  late DomainDependencyCycleScanner scanner;

  setUpAll(() {
    scanner = DomainDependencyCycleScanner();
  });

  group('Mentora Circular Dependency Governance — '
      'Sprint -1.2 / Lot D.5', () {
    test('ARC-D12 approved dependency policy '
        'must be acyclic', () {
      final cycles = scanner.policyCycleSignatures().toList()..sort();

      expect(
        cycles,
        isEmpty,
        reason: _failureMessage(
          rule: 'ARC-D12',
          message:
              'The approved dependency policy '
              'contains a cycle.',
          cycles: cycles,
        ),
      );
    });

    test('ARC-D13 registered domain import graph '
        'must be acyclic', () {
      final cycles = scanner.actualCycleSignatures().toList()..sort();

      expect(
        cycles,
        isEmpty,
        reason: _failureMessage(
          rule: 'ARC-D13',
          message:
              'Registered Mentora domains contain '
              'a compile-time cycle.',
          cycles: cycles,
        ),
      );
    });
  });
}

String _failureMessage({
  required String rule,
  required String message,
  required List<String> cycles,
}) {
  if (cycles.isEmpty) {
    return '';
  }

  final buffer = StringBuffer()
    ..writeln('$rule failed.')
    ..writeln(message)
    ..writeln()
    ..writeln('Cycle group(s):');

  for (final cycle in cycles) {
    buffer.writeln(' - $cycle');
  }

  buffer
    ..writeln()
    ..writeln('Do not baseline a new owned-domain cycle.')
    ..writeln(
      'Break the compile-time dependency using '
      'a public contract, event, gateway or '
      'dependency inversion.',
    );

  return buffer.toString();
}
