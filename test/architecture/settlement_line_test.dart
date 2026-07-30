import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/settlement/settlements.dart';
import 'package:mentora/core/financial/domain/shared/money/financial_currency.dart';
import 'package:mentora/core/financial/domain/shared/money/money.dart';
import 'package:mentora/core/financial/domain/primitives/percentage/percentage.dart';
import 'package:mentora/core/financial/domain/shared/rates/revenue_share.dart';

void main() {
  group('SettlementLine', () {
    late Money amount;
    late RevenueShare rate;

    setUp(() {
      amount = Money(minorUnits: 8500, currency: FinancialCurrency.xof);

      rate = RevenueShare(Percentage.fromWholePercent(85));
    });

    test('creates a valid settlement line', () {
      final line = SettlementLine(
        party: SettlementParty.expert,
        rate: rate,
        amount: amount,
      );

      expect(line.party, SettlementParty.expert);
      expect(line.rate, rate);
      expect(line.amount, amount);
    });

    test('isPositive returns true for a positive amount', () {
      final line = SettlementLine(
        party: SettlementParty.expert,
        rate: rate,
        amount: amount,
      );

      expect(line.isPositive, isTrue);
      expect(line.isZero, isFalse);
    });

    test('isZero returns true for a zero amount', () {
      final line = SettlementLine(
        party: SettlementParty.platform,
        rate: RevenueShare(Percentage.zero),
        amount: Money.zero(FinancialCurrency.xof),
      );

      expect(line.isZero, isTrue);
      expect(line.isPositive, isFalse);
    });

    test('copyWith updates only modified fields', () {
      final original = SettlementLine(
        party: SettlementParty.expert,
        rate: rate,
        amount: amount,
      );

      final updated = original.copyWith(party: SettlementParty.platform);

      expect(updated.party, SettlementParty.platform);
      expect(updated.rate, original.rate);
      expect(updated.amount, original.amount);
    });

    test('two identical settlement lines are equal', () {
      final first = SettlementLine(
        party: SettlementParty.expert,
        rate: rate,
        amount: amount,
      );

      final second = SettlementLine(
        party: SettlementParty.expert,
        rate: rate,
        amount: amount,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('different parties produce different settlement lines', () {
      final first = SettlementLine(
        party: SettlementParty.expert,
        rate: rate,
        amount: amount,
      );

      final second = SettlementLine(
        party: SettlementParty.platform,
        rate: rate,
        amount: amount,
      );

      expect(first, isNot(second));
    });

    test('toString contains useful diagnostic information', () {
      final line = SettlementLine(
        party: SettlementParty.expert,
        rate: rate,
        amount: amount,
      );

      expect(line.toString(), contains('SettlementLine'));

      expect(line.toString(), contains('expert'));
    });
  });
}
