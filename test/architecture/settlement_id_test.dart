import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/financial/domain/settlement/settlements.dart';
import 'package:mentora/core/financial/domain/shared/exceptions/invalid_financial_identifier_exception.dart';

void main() {
  group('SettlementId', () {
    test('creates a valid settlement identifier', () {
      final SettlementId id = SettlementId('settlement_001');

      expect(id.value, 'settlement_001');
      expect(id.toPrimitive(), 'settlement_001');
      expect(id.toString(), 'SettlementId(settlement_001)');
    });

    test('trims surrounding whitespace', () {
      final SettlementId id = SettlementId('  settlement_001  ');

      expect(id.value, 'settlement_001');
    });

    test('creates an identifier from a raw string', () {
      final SettlementId id = SettlementId.fromString('settlement_002');

      expect(id.value, 'settlement_002');
    });

    test('two settlement identifiers with the same value are equal', () {
      final SettlementId first = SettlementId('settlement_001');
      final SettlementId second = SettlementId('settlement_001');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('two settlement identifiers with different values are not equal', () {
      final SettlementId first = SettlementId('settlement_001');
      final SettlementId second = SettlementId('settlement_002');

      expect(first, isNot(second));
    });

    test('throws when the identifier is empty', () {
      expect(
        () => SettlementId(''),
        throwsA(isA<InvalidFinancialIdentifierException>()),
      );
    });

    test('throws when the identifier contains only whitespace', () {
      expect(
        () => SettlementId('   '),
        throwsA(isA<InvalidFinancialIdentifierException>()),
      );
    });
  });
}
