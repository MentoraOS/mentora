import '../models/ledger_entry.dart';
import '../models/ledger_transaction.dart';

abstract class LedgerRepository {
  Future<void> saveTransaction(LedgerTransaction transaction);

  Future<LedgerTransaction?> findTransactionById(String transactionId);

  Future<LedgerTransaction?> findTransactionByReferenceId(String referenceId);

  Future<List<LedgerTransaction>> findTransactionsByAccountId(String accountId);

  Future<List<LedgerEntry>> findEntriesByAccountId(String accountId);

  Future<bool> existsByTransactionId(String transactionId);

  Future<bool> existsByReferenceId(String referenceId);
}
