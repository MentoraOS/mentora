import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/financial/domain/shared/exceptions/currency_mismatch_exception.dart';
import 'package:mentora/core/financial/domain/shared/exceptions/invalid_money_amount_exception.dart';
import 'package:mentora/core/financial/domain/shared/money/financial_currency.dart';
import 'package:mentora/core/financial/domain/shared/money/money.dart';

void main() {
  group('Money', () {
    test('creates an immutable amount in minor units', () {
      final money = Money(minorUnits: 10000, currency: FinancialCurrency.xof);

      expect(money.minorUnits, 10000);
      expect(money.currency, FinancialCurrency.xof);
      expect(money.isPositive, isTrue);
      expect(money.isZero, isFalse);
    });

    test('creates zero explicitly', () {
      final money = Money.zero(FinancialCurrency.eur);

      expect(money.minorUnits, 0);
      expect(money.isZero, isTrue);
      expect(money.isPositive, isFalse);
    });

    test('rejects negative minor units at runtime', () {
      expect(
        () => Money(minorUnits: -1, currency: FinancialCurrency.usd),
        throwsA(isA<InvalidMoneyAmountException>()),
      );
    });

    test('adds amounts with the same currency', () {
      final left = Money(minorUnits: 1200, currency: FinancialCurrency.usd);
      final right = Money(minorUnits: 300, currency: FinancialCurrency.usd);

      expect((left + right).minorUnits, 1500);
      expect((left + right).currency, FinancialCurrency.usd);
    });

    test('subtracts amounts while preserving non-negative invariant', () {
      final left = Money(minorUnits: 1200, currency: FinancialCurrency.usd);
      final right = Money(minorUnits: 300, currency: FinancialCurrency.usd);

      expect((left - right).minorUnits, 900);
    });

    test('rejects subtraction that would produce a negative amount', () {
      final left = Money(minorUnits: 300, currency: FinancialCurrency.usd);
      final right = Money(minorUnits: 1200, currency: FinancialCurrency.usd);

      expect(() => left - right, throwsA(isA<InvalidMoneyAmountException>()));
    });

    test('rejects arithmetic across different currencies', () {
      final usd = Money(minorUnits: 100, currency: FinancialCurrency.usd);
      final eur = Money(minorUnits: 100, currency: FinancialCurrency.eur);

      expect(() => usd + eur, throwsA(isA<CurrencyMismatchException>()));
      expect(() => usd - eur, throwsA(isA<CurrencyMismatchException>()));
    });

    test('compares only values expressed in the same currency', () {
      final low = Money(minorUnits: 100, currency: FinancialCurrency.xof);
      final high = Money(minorUnits: 200, currency: FinancialCurrency.xof);

      expect(low.isLessThan(high), isTrue);
      expect(low.isLessThanOrEqualTo(high), isTrue);
      expect(high.isGreaterThan(low), isTrue);
      expect(high.isGreaterThanOrEqualTo(low), isTrue);
    });

    test('rejects comparison across different currencies', () {
      final usd = Money(minorUnits: 100, currency: FinancialCurrency.usd);
      final eur = Money(minorUnits: 100, currency: FinancialCurrency.eur);

      expect(
        () => usd.compareTo(eur),
        throwsA(isA<CurrencyMismatchException>()),
      );
    });

    test('value equality includes amount and currency', () {
      final first = Money(minorUnits: 500, currency: FinancialCurrency.gbp);
      final same = Money(minorUnits: 500, currency: FinancialCurrency.gbp);
      final differentAmount = Money(
        minorUnits: 501,
        currency: FinancialCurrency.gbp,
      );
      final differentCurrency = Money(
        minorUnits: 500,
        currency: FinancialCurrency.eur,
      );

      expect(first, same);
      expect(first.hashCode, same.hashCode);
      expect(first, isNot(differentAmount));
      expect(first, isNot(differentCurrency));
    });
  });
}
