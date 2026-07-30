import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/financial/domain/primitives/percentage/percentage.dart';
import 'package:mentora/core/financial/domain/primitives/percentage/percentage_exception.dart';
import 'package:mentora/core/financial/domain/shared/money/financial_currency.dart';
import 'package:mentora/core/financial/domain/shared/money/money.dart';

void main() {
  group('Percentage', () {
    test('creates zero and one hundred percent', () {
      expect(Percentage.zero.partsPerMillion, 0);
      expect(Percentage.oneHundred.partsPerMillion, 1000000);
    });

    test('creates a percentage from whole percent', () {
      final Percentage percentage = Percentage.fromWholePercent(18);

      expect(percentage.partsPerMillion, 180000);
      expect(percentage.toString(), '18%');
    });

    test('creates a percentage from basis points', () {
      final Percentage percentage = Percentage.fromBasisPoints(75);

      expect(percentage.partsPerMillion, 7500);
      expect(percentage.basisPoints, 75);
      expect(percentage.toString(), '0.75%');
    });

    test('parses percentages without using double', () {
      expect(Percentage.parse('0.75').partsPerMillion, 7500);

      expect(Percentage.parse('18').partsPerMillion, 180000);

      expect(Percentage.parse('12,3456').partsPerMillion, 123456);
    });

    test('rejects a negative percentage', () {
      expect(
        () => Percentage.fromPartsPerMillion(-1),
        throwsA(isA<InvalidPercentageException>()),
      );
    });

    test('rejects a percentage above one hundred', () {
      expect(
        () => Percentage.fromPartsPerMillion(1000001),
        throwsA(isA<InvalidPercentageException>()),
      );
    });

    test('adds two percentages', () {
      final Percentage first = Percentage.fromWholePercent(10);

      final Percentage second = Percentage.fromWholePercent(8);

      expect(first + second, Percentage.fromWholePercent(18));
    });

    test('rejects negative subtraction results', () {
      final Percentage smaller = Percentage.fromWholePercent(10);

      final Percentage larger = Percentage.fromWholePercent(18);

      expect(
        () => smaller - larger,
        throwsA(isA<InvalidPercentageException>()),
      );
    });

    test('applies percentage to Money using half-up rounding', () {
      final Money amount = Money(
        minorUnits: 10000,
        currency: FinancialCurrency.xof,
      );

      final Percentage rate = Percentage.fromBasisPoints(75);

      final Money result = rate.applyTo(amount);

      expect(result.minorUnits, 75);
      expect(result.currency, FinancialCurrency.xof);
    });

    test('supports explicit downward rounding', () {
      final Money amount = Money(
        minorUnits: 101,
        currency: FinancialCurrency.xof,
      );

      final Percentage rate = Percentage.fromWholePercent(10);

      final Money result = rate.applyTo(
        amount,
        roundingMode: FinancialRoundingMode.down,
      );

      expect(result.minorUnits, 10);
    });

    test('supports explicit upward rounding', () {
      final Money amount = Money(
        minorUnits: 101,
        currency: FinancialCurrency.xof,
      );

      final Percentage rate = Percentage.fromWholePercent(10);

      final Money result = rate.applyTo(
        amount,
        roundingMode: FinancialRoundingMode.up,
      );

      expect(result.minorUnits, 11);
    });

    test('uses value equality', () {
      final Percentage first = Percentage.fromBasisPoints(75);

      final Percentage same = Percentage.parse('0.75');

      expect(first, same);
      expect(first.hashCode, same.hashCode);
    });

    test('compares percentages', () {
      final Percentage ten = Percentage.fromWholePercent(10);

      final Percentage eighteen = Percentage.fromWholePercent(18);

      expect(ten < eighteen, isTrue);
      expect(eighteen > ten, isTrue);
      expect(ten <= ten, isTrue);
      expect(eighteen >= ten, isTrue);
    });
  });
}
