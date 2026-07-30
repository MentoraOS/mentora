import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_trial_balance_entry.dart';

void main() {
  group('LedgerTrialBalanceEntry', () {
    test('creates a valid entry', () {
      const entry = LedgerTrialBalanceEntry(
        accountId: 'platform_cash_XOF',
        currency: 'XOF',
        totalDebitMinor: 500000,
        totalCreditMinor: 120000,
        entryCount: 8,
      );

      expect(entry.accountId, 'platform_cash_XOF');
      expect(entry.currency, 'XOF');
      expect(entry.totalDebitMinor, 500000);
      expect(entry.totalCreditMinor, 120000);
      expect(entry.entryCount, 8);
    });

    test('calculates a debit balance', () {
      const entry = LedgerTrialBalanceEntry(
        accountId: 'platform_cash_XOF',
        currency: 'XOF',
        totalDebitMinor: 1000,
        totalCreditMinor: 300,
        entryCount: 2,
      );

      expect(entry.balanceMinor, 700);
      expect(entry.hasDebitBalance, isTrue);
      expect(entry.hasCreditBalance, isFalse);
      expect(entry.isZeroBalance, isFalse);
    });

    test('calculates a credit balance', () {
      const entry = LedgerTrialBalanceEntry(
        accountId: 'platform_revenue_XOF',
        currency: 'XOF',
        totalDebitMinor: 100,
        totalCreditMinor: 900,
        entryCount: 2,
      );

      expect(entry.balanceMinor, -800);
      expect(entry.hasCreditBalance, isTrue);
      expect(entry.hasDebitBalance, isFalse);
    });

    test('detects a zero balance', () {
      const entry = LedgerTrialBalanceEntry(
        accountId: 'platform_clearing_USD',
        currency: 'USD',
        totalDebitMinor: 2000,
        totalCreditMinor: 2000,
        entryCount: 4,
      );

      expect(entry.balanceMinor, 0);
      expect(entry.isZeroBalance, isTrue);
    });

    test('supports immutable copies', () {
      const original = LedgerTrialBalanceEntry(
        accountId: 'platform_cash_XOF',
        currency: 'XOF',
        totalDebitMinor: 1000,
        totalCreditMinor: 200,
        entryCount: 2,
      );

      final updated = original.copyWith(totalCreditMinor: 400, entryCount: 3);

      expect(original.totalCreditMinor, 200);
      expect(original.entryCount, 2);

      expect(updated.totalCreditMinor, 400);
      expect(updated.entryCount, 3);
      expect(updated.balanceMinor, 600);
    });

    test('supports value equality', () {
      const first = LedgerTrialBalanceEntry(
        accountId: 'platform_cash_XOF',
        currency: 'XOF',
        totalDebitMinor: 1000,
        totalCreditMinor: 200,
        entryCount: 2,
      );

      const second = LedgerTrialBalanceEntry(
        accountId: 'platform_cash_XOF',
        currency: 'XOF',
        totalDebitMinor: 1000,
        totalCreditMinor: 200,
        entryCount: 2,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('converts to map', () {
      const entry = LedgerTrialBalanceEntry(
        accountId: 'platform_cash_XOF',
        currency: 'XOF',
        totalDebitMinor: 1000,
        totalCreditMinor: 200,
        entryCount: 2,
      );

      expect(entry.toMap(), {
        'accountId': 'platform_cash_XOF',
        'currency': 'XOF',
        'totalDebitMinor': 1000,
        'totalCreditMinor': 200,
        'entryCount': 2,
        'balanceMinor': 800,
      });
    });
  });
}
