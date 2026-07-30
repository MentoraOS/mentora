import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/settlement/settlements.dart';
import 'package:mentora/core/financial/domain/shared/money/financial_currency.dart';
import 'package:mentora/core/financial/domain/shared/money/money.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/models/settlement_posting_line.dart';
import 'package:mentora/core/financial/orchestrator/workflows/financial_posting/models/settlement_posting_category.dart';

void main() {
  group('SettlementPostingLine', () {
    SettlementPostingLine createLine({
      SettlementParty party = SettlementParty.expert,
      SettlementPostingCategory category =
          SettlementPostingCategory.expertRevenue,
      int minorUnits = 8500,
      String code = 'EXPERT_REVENUE',
      String label = 'Expert revenue',
    }) {
      return SettlementPostingLine(
        party: party,
        category: category,
        amount: Money(minorUnits: minorUnits, currency: FinancialCurrency.xof),
        code: code,
        label: label,
      );
    }

    test('creates a valid posting line', () {
      final line = createLine();

      expect(line.party, SettlementParty.expert);
      expect(line.amount.minorUnits, 8500);
      expect(line.amount.currency, FinancialCurrency.xof);
      expect(line.code, 'EXPERT_REVENUE');
      expect(line.label, 'Expert revenue');
      expect(line.isPositive, isTrue);
      expect(line.isZero, isFalse);
      expect(line.category, SettlementPostingCategory.expertRevenue);
    });

    test('normalizes code and label', () {
      final line = createLine(
        code: '  EXPERT_REVENUE  ',
        label: '  Expert revenue  ',
      );

      expect(line.code, 'EXPERT_REVENUE');
      expect(line.label, 'Expert revenue');
    });

    test('supports a zero amount', () {
      final line = createLine(minorUnits: 0);

      expect(line.isPositive, isFalse);
      expect(line.isZero, isTrue);
    });

    test('copyWith changes selected values', () {
      final original = createLine();

      final updated = original.copyWith(
        party: SettlementParty.platform,
        category: SettlementPostingCategory.platformRevenue,
        amount: Money(minorUnits: 1500, currency: FinancialCurrency.xof),
        code: 'PLATFORM_REVENUE',
        label: 'Platform revenue',
      );

      expect(updated.party, SettlementParty.platform);
      expect(updated.amount.minorUnits, 1500);
      expect(updated.code, 'PLATFORM_REVENUE');
      expect(updated.label, 'Platform revenue');

      expect(original.party, SettlementParty.expert);
      expect(original.amount.minorUnits, 8500);
      expect(updated.category, SettlementPostingCategory.platformRevenue);
    });

    test('different categories produce different posting lines', () {
      final first = createLine();

      final second = createLine(
        category: SettlementPostingCategory.platformRevenue,
      );

      expect(first, isNot(second));
      expect(first.hashCode, isNot(second.hashCode));
    });

    test('copyWith preserves omitted values', () {
      final original = createLine();

      final copy = original.copyWith();

      expect(copy, original);
      expect(copy.hashCode, original.hashCode);
    });

    test('identical posting lines are equal', () {
      final first = createLine();
      final second = createLine();

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('different posting lines are not equal', () {
      final first = createLine();

      final second = createLine(code: 'PLATFORM_REVENUE');

      expect(first, isNot(second));
    });

    test('rejects an empty code', () {
      expect(
        () => createLine(code: ''),
        throwsA(
          isA<ArgumentError>().having((error) => error.name, 'name', 'code'),
        ),
      );
    });

    test('rejects a whitespace-only code', () {
      expect(() => createLine(code: '   '), throwsA(isA<ArgumentError>()));
    });

    test('rejects an empty label', () {
      expect(
        () => createLine(label: ''),
        throwsA(
          isA<ArgumentError>().having((error) => error.name, 'name', 'label'),
        ),
      );
    });

    test('rejects a whitespace-only label', () {
      expect(() => createLine(label: '   '), throwsA(isA<ArgumentError>()));
    });

    test('toString contains useful information', () {
      final line = createLine();

      final value = line.toString();

      expect(value, contains('SettlementPostingLine'));
      expect(value, contains('EXPERT_REVENUE'));
      expect(value, contains('Expert revenue'));
      expect(value, contains('8500'));
    });
  });
}
