import '../models/ledger_transaction.dart';
import 'ledger_repository.dart';

final class InMemoryLedgerRepository implements LedgerRepository {
  final List<LedgerTransaction> _transactions = [];

  @override
  Future<void> saveTransaction(LedgerTransaction transaction) async {
    final existing = await findById(transaction.id);

    if (existing != null) {
      return;
    }

    _transactions.add(transaction);
  }

  @override
  Future<LedgerTransaction?> findById(String transactionId) async {
    try {
      return _transactions.firstWhere(
        (transaction) => transaction.id == transactionId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LedgerTransaction>> findByReferenceId(String referenceId) async {
    return _transactions
        .where((transaction) => transaction.reference == referenceId)
        .toList(growable: false);
  }

  @override
  Future<List<LedgerTransaction>> transactionsForAccount(
    String accountId,
  ) async {
    return _transactions
        .where((transaction) {
          return transaction.entries.any(
            (entry) => entry.accountId == accountId,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<bool> exists(String transactionId) async {
    return _transactions.any((transaction) => transaction.id == transactionId);
  }

  List<LedgerTransaction> get allTransactions =>
      List.unmodifiable(_transactions);

  void clear() {
    _transactions.clear();
  }
}
