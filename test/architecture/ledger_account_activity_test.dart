import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_account_activity.dart';

void main() {
  group('LedgerAccountActivity', () {
    test('creates a valid activity', () {
      const activity = LedgerAccountActivity(
        accountId: 'cash',
        currency: 'XOF',
        entryCount: 12,
        totalDebitMinor: 500000,
        totalCreditMinor: 120000,
      );

      expect(activity.accountId, 'cash');
      expect(activity.currency, 'XOF');
      expect(activity.entryCount, 12);
      expect(activity.totalDebitMinor, 500000);
      expect(activity.totalCreditMinor, 120000);
    });

    test('calculates debit balance', () {
      const activity = LedgerAccountActivity(
        accountId: 'cash',
        currency: 'XOF',
        entryCount: 1,
        totalDebitMinor: 1000,
        totalCreditMinor: 200,
      );

      expect(activity.balanceMinor, 800);
      expect(activity.isDebitBalance, isTrue);
      expect(activity.isCreditBalance, isFalse);
      expect(activity.isBalanced, isFalse);
    });

    test('calculates credit balance', () {
      const activity = LedgerAccountActivity(
        accountId: 'revenue',
        currency: 'XOF',
        entryCount: 1,
        totalDebitMinor: 300,
        totalCreditMinor: 900,
      );

      expect(activity.balanceMinor, -600);
      expect(activity.isCreditBalance, isTrue);
    });

    test('detects balanced account', () {
      const activity = LedgerAccountActivity(
        accountId: 'escrow',
        currency: 'USD',
        entryCount: 5,
        totalDebitMinor: 2000,
        totalCreditMinor: 2000,
      );

      expect(activity.balanceMinor, 0);
      expect(activity.isBalanced, isTrue);
    });

    test('supports copyWith', () {
      const original = LedgerAccountActivity(
        accountId: 'cash',
        currency: 'XOF',
        entryCount: 2,
        totalDebitMinor: 100,
        totalCreditMinor: 50,
      );

      final updated = original.copyWith(entryCount: 10);

      expect(original.entryCount, 2);
      expect(updated.entryCount, 10);
    });

    test('supports equality', () {
      const first = LedgerAccountActivity(
        accountId: 'cash',
        currency: 'USD',
        entryCount: 1,
        totalDebitMinor: 100,
        totalCreditMinor: 50,
      );

      const second = LedgerAccountActivity(
        accountId: 'cash',
        currency: 'USD',
        entryCount: 1,
        totalDebitMinor: 100,
        totalCreditMinor: 50,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('converts to map', () {
      const activity = LedgerAccountActivity(
        accountId: 'cash',
        currency: 'USD',
        entryCount: 5,
        totalDebitMinor: 1000,
        totalCreditMinor: 400,
      );

      expect(activity.toMap(), {
        'accountId': 'cash',
        'currency': 'USD',
        'entryCount': 5,
        'totalDebitMinor': 1000,
        'totalCreditMinor': 400,
        'balanceMinor': 600,
      });
    });
  });
}
