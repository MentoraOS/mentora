import 'models/ledger_entry.dart';
import 'models/ledger_transaction.dart';
import 'repository/ledger_repository.dart';

class LedgerEngine {
  final LedgerRepository repository;

  const LedgerEngine({required this.repository});

  bool isBalanced(LedgerTransaction transaction) {
    final debitTotal = transaction.entries
        .where((entry) => entry.type == LedgerEntryType.debit)
        .fold<int>(0, (sum, entry) => sum + entry.amount);

    final creditTotal = transaction.entries
        .where((entry) => entry.type == LedgerEntryType.credit)
        .fold<int>(0, (sum, entry) => sum + entry.amount);

    return debitTotal == creditTotal;
  }

  Future<void> recordTransaction(LedgerTransaction transaction) async {
    if (!isBalanced(transaction)) {
      throw Exception(
        'Ledger transaction rejected: debits and credits are not balanced.',
      );
    }

    await repository.saveTransaction(transaction);
  }

  Future<int> balanceOf(String accountId) async {
    final transactions = await repository.transactionsForAccount(accountId);

    int balance = 0;

    for (final transaction in transactions) {
      for (final entry in transaction.entries) {
        if (entry.accountId != accountId) continue;

        if (entry.type == LedgerEntryType.credit) {
          balance += entry.amount;
        } else {
          balance -= entry.amount;
        }
      }
    }

    return balance;
  }
}
