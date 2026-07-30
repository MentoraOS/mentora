import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/financial/domain/shared/exceptions/invalid_financial_currency_exception.dart';
import 'package:mentora/core/financial/domain/shared/money/financial_currency.dart';

void main() {
  group('FinancialCurrency', () {
    test('exposes immutable metadata for supported currencies', () {
      expect(FinancialCurrency.xof.code, 'XOF');
      expect(FinancialCurrency.xof.minorUnitDigits, 0);
      expect(FinancialCurrency.xof.minorUnitFactor, 1);

      expect(FinancialCurrency.usd.code, 'USD');
      expect(FinancialCurrency.usd.minorUnitDigits, 2);
      expect(FinancialCurrency.usd.minorUnitFactor, 100);
    });

    test('resolves a currency with normalized input', () {
      expect(FinancialCurrency.fromCode(' usd '), FinancialCurrency.usd);
      expect(FinancialCurrency.fromCode('xof'), FinancialCurrency.xof);
    });

    test('tryFromCode returns null for absent or unsupported codes', () {
      expect(FinancialCurrency.tryFromCode(null), isNull);
      expect(FinancialCurrency.tryFromCode('ABC'), isNull);
    });

    test('fromCode rejects unsupported codes with a domain exception', () {
      expect(
        () => FinancialCurrency.fromCode('ABC'),
        throwsA(isA<InvalidFinancialCurrencyException>()),
      );
    });

    test('equality and hashCode are based on ISO code', () {
      final resolved = FinancialCurrency.fromCode('USD');

      expect(resolved, FinancialCurrency.usd);
      expect(resolved.hashCode, FinancialCurrency.usd.hashCode);
    });
  });
}
