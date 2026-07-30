import '../models/ledger_transaction.dart';

// Persistence contract for ledger transactions.
//
// The repository supports:
// - durable transaction storage;
// - direct lookup for idempotence and recovery;
// - reference-based lookup for audit workflows;
// - account history queries.

abstract interface class LedgerRepository {
  Future<void> saveTransaction(LedgerTransaction transaction);

  Future<LedgerTransaction?> findById(String transactionId);

  Future<List<LedgerTransaction>> findByReferenceId(String referenceId);

  Future<List<LedgerTransaction>> transactionsForAccount(String accountId);

  Future<bool> exists(String transactionId);
}
