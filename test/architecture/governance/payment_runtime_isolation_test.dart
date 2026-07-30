import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'payment_runtime_boundary_registry.dart';
import 'payment_runtime_scanner.dart';

void main() {
  group('Mentora Payment Production Isolation — '
      'Sprint -1.2 / Lot E.5.1', () {
    test('ARC-E11 MockPaymentProvider must not be '
        'reachable from runtime code', () {
      final scanner = PaymentRuntimeScanner();

      final violations = scanner.scan();

      expect(violations, isEmpty, reason: _failureMessage(violations));
    });

    test('ARC-E12 mock declaration remains isolated '
        'in its dedicated provider file', () {
      final root = _projectRoot();

      final declaration = File(
        '${root.path}/lib/'
        'core/engines/payment/providers/'
        'mock_payment_provider.dart',
      );

      expect(
        declaration.existsSync(),
        isTrue,
        reason:
            'Expected MockPaymentProvider declaration '
            'file was not found.',
      );

      final content = declaration.readAsStringSync();

      expect(
        content.contains('MockPaymentProvider'),
        isTrue,
        reason:
            'The dedicated mock provider file no '
            'longer declares MockPaymentProvider.',
      );
    });

    test('ARC-E13 production Payment public facade '
        'must not export the mock provider', () {
      final root = _projectRoot();

      final facade = File('${root.path}/lib/core/payment/payment.dart');

      if (!facade.existsSync()) {
        fail(
          'Payment public facade is missing: '
          'lib/core/payment/payment.dart',
        );
      }

      final source = facade.readAsStringSync();

      final violations = PaymentRuntimeBoundaryRegistry
          .forbiddenRuntimeImportFragments
          .where(source.contains)
          .toList();

      expect(
        violations,
        isEmpty,
        reason:
            'Payment public API exposes mock '
            'implementation(s): '
            '${violations.join(', ')}',
      );
    });
  });
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
      throw StateError('Unable to locate Mentora project root.');
    }

    current = parent;
  }
}

String _failureMessage(List<PaymentRuntimeViolation> violations) {
  if (violations.isEmpty) {
    return '';
  }

  final buffer = StringBuffer()
    ..writeln('ARC-E11 failed.')
    ..writeln()
    ..writeln(
      'Mock payment infrastructure is reachable '
      'from production runtime code.',
    )
    ..writeln()
    ..writeln('This is a P0 production-safety violation.')
    ..writeln()
    ..writeln('Do NOT baseline this violation.')
    ..writeln()
    ..writeln('Runtime reference(s):');

  for (final violation in violations) {
    buffer.writeln(' - ${violation.fingerprint}');
  }

  return buffer.toString();
}
