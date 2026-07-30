import '../chart/chart_of_accounts.dart';
import '../models/ledger_balance.dart';
import '../models/ledger_entry_side.dart';
import '../repositories/ledger_repository.dart';
import 'ledger_normal_balance_calculator.dart';

class BalanceEngine {
  final LedgerRepository repository;
  final ChartOfAccounts chartOfAccounts;
  final LedgerNormalBalanceCalculator normalBalanceCalculator;

  const BalanceEngine({
    required this.repository,
    required this.chartOfAccounts,
    this.normalBalanceCalculator = const LedgerNormalBalanceCalculator(),
  });

  Future<LedgerBalance> calculate(String accountId) async {
    final account = chartOfAccounts.getRequiredAccount(accountId);

    if (!account.active) {
      throw StateError(
        'Cannot calculate balance for inactive account ${account.id}',
      );
    }

    final entries = await repository.findEntriesByAccountId(account.id);

    var debitMinor = 0;
    var creditMinor = 0;

    for (final entry in entries) {
      if (entry.currency.toUpperCase() != account.currency.toUpperCase()) {
        throw StateError(
          'Ledger entry ${entry.id} uses currency '
          '${entry.currency}, but account ${account.id} '
          'uses ${account.currency}',
        );
      }

      switch (entry.side) {
        case LedgerEntrySide.debit:
          debitMinor += entry.amountMinor;
          break;

        case LedgerEntrySide.credit:
          creditMinor += entry.amountMinor;
          break;
      }
    }

    final balanceMinor = normalBalanceCalculator.calculate(
      accountType: account.type,
      debitMinor: debitMinor,
      creditMinor: creditMinor,
    );

    return LedgerBalance(
      accountId: account.id,
      currency: account.currency,
      debitMinor: debitMinor,
      creditMinor: creditMinor,
      balanceMinor: balanceMinor,
    );
  }
}
