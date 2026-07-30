import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/reporting/ledger_trial_balance.dart';
import 'package:mentora/core/financial/ledger/journal/reporting/ledger_trial_balance_entry.dart';

void main() {
  group('LedgerTrialBalance', () {
    late LedgerTrialBalance balance;

    setUp(() {
      balance = LedgerTrialBalance(
        entries: [
          const LedgerTrialBalanceEntry(
            accountId: 'cash_XOF',
            currency: 'XOF',
            totalDebitMinor: 500000,
            totalCreditMinor: 0,
            entryCount: 5,
          ),
          const LedgerTrialBalanceEntry(
            accountId: 'escrow_XOF',
            currency: 'XOF',
            totalDebitMinor: 250000,
            totalCreditMinor: 0,
            entryCount: 3,
          ),
          const LedgerTrialBalanceEntry(
            accountId: 'platform_revenue_XOF',
            currency: 'XOF',
            totalDebitMinor: 0,
            totalCreditMinor: 50000,
            entryCount: 1,
          ),
          const LedgerTrialBalanceEntry(
            accountId: 'expert_wallet_XOF',
            currency: 'XOF',
            totalDebitMinor: 0,
            totalCreditMinor: 700000,
            entryCount: 7,
          ),
        ],
      );
    });

    test('calculates totals', () {
      expect(balance.totalDebitMinor, 750000);
      expect(balance.totalCreditMinor, 750000);
      expect(balance.balanceMinor, 0);
      expect(balance.isBalanced, isTrue);
    });

    test('returns account count', () {
      expect(balance.accountCount, 4);
    });

    test('returns entry count', () {
      expect(balance.entryCount, 16);
    });

    test('returns currencies', () {
      expect(balance.currencies, {'XOF'});
    });

    test('finds an account', () {
      final account = balance.account('cash_XOF');

      expect(account, isNotNull);
      expect(account!.totalDebitMinor, 500000);
    });

    test('returns null for missing account', () {
      expect(balance.account('missing'), isNull);
    });

    test('exports to map', () {
      final map = balance.toMap();

      expect(map['accountCount'], 4);
      expect(map['entryCount'], 16);
      expect(map['isBalanced'], isTrue);
    });

    test('supports value equality', () {
      final copy = LedgerTrialBalance(entries: balance.entries);

      expect(copy, balance);
      expect(copy.hashCode, balance.hashCode);
    });
  });
}
