import '../chart/chart_of_accounts.dart';
import '../models/ledger_transaction.dart';
import '../repositories/ledger_repository.dart';

class LedgerEngine {
  final LedgerRepository repository;
  final ChartOfAccounts chartOfAccounts;

  const LedgerEngine({required this.repository, required this.chartOfAccounts});

  Future<LedgerTransaction> post(LedgerTransaction transaction) async {
    _validateAccounts(transaction);

    await repository.saveTransaction(transaction);

    final savedTransaction = await repository.findTransactionById(
      transaction.id,
    );

    if (savedTransaction == null) {
      throw StateError(
        'Ledger transaction ${transaction.id} was not persisted',
      );
    }

    return savedTransaction;
  }

  Future<LedgerTransaction?> findById(String transactionId) {
    return repository.findTransactionById(transactionId);
  }

  Future<LedgerTransaction?> findByReferenceId(String referenceId) {
    return repository.findTransactionByReferenceId(referenceId);
  }

  void _validateAccounts(LedgerTransaction transaction) {
    for (final entry in transaction.entries) {
      final account = chartOfAccounts.getRequiredAccount(entry.accountId);

      if (!account.active) {
        throw StateError('Ledger account ${account.id} is inactive');
      }

      if (account.currency.toUpperCase() !=
          transaction.currency.toUpperCase()) {
        throw StateError(
          'Ledger account ${account.id} uses currency '
          '${account.currency}, but transaction '
          '${transaction.id} uses ${transaction.currency}',
        );
      }

      if (entry.currency.toUpperCase() != account.currency.toUpperCase()) {
        throw StateError(
          'Ledger entry ${entry.id} uses currency '
          '${entry.currency}, but account '
          '${account.id} uses ${account.currency}',
        );
      }
    }
  }
}
