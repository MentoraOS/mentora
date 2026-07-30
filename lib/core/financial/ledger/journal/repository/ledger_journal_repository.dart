import '../models/ledger_journal.dart';
import '../models/ledger_journal_status.dart';

// Persistence contract for ledger journals.
//
// Implementations may use memory, SQLite, PostgreSQL, Firestore,
// CockroachDB or another durable storage engine.
abstract interface class LedgerJournalRepository {
  // Persists a new journal.
  //
  // Implementations must reject:
  // - duplicate journal IDs;
  // - duplicate operation IDs.
  Future<void> create(LedgerJournal journal);

  // Updates an existing journal using optimistic versioning.
  //
  // [expectedVersion] must match the currently stored version.
  Future<void> update({
    required LedgerJournal journal,
    required int expectedVersion,
  });

  // Returns a journal by its unique identifier.
  Future<LedgerJournal?> findById(String journalId);

  // Returns the journal associated with one business operation.
  Future<LedgerJournal?> findByOperationId(String operationId);

  // Returns every stored journal.
  Future<List<LedgerJournal>> findAll();

  // Returns journals having the requested lifecycle status.
  Future<List<LedgerJournal>> findByStatus(LedgerJournalStatus status);

  // Returns journals produced by a workflow.
  Future<List<LedgerJournal>> findByWorkflowKey(String workflowKey);

  // Returns journals produced by a specific source.
  Future<List<LedgerJournal>> findBySource({
    required String sourceType,
    required String sourceId,
  });

  // Returns journals whose occurrence time is within:
  //
  // [from] inclusive
  // [to] exclusive
  Future<List<LedgerJournal>> findOccurredBetween({
    required DateTime from,
    required DateTime to,
  });

  // Indicates whether a journal exists for the supplied operation.
  Future<bool> existsByOperationId(String operationId);

  // Returns the number of stored journals.
  Future<int> count();

  // Executes [action] atomically against a transactional repository view.
  //
  // Every change is committed only when [action] completes successfully.
  // If [action] throws, all staged changes are discarded.
  Future<T> runInTransaction<T>(
    Future<T> Function(LedgerJournalRepository repository) action,
  );
}
