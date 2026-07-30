import '../../models/ledger_transaction.dart';

import '../models/ledger_journal.dart';

// Result of a successful dual posting.
//
// Both objects represent the same accounting operation:
// - [transaction] is the transaction-oriented ledger record;
// - [journal] is the posted journal projection.

final class LedgerJournalPostingResult {
  const LedgerJournalPostingResult({
    required this.transaction,
    required this.journal,
    required this.wasAlreadyJournalized,
  });

  final LedgerTransaction transaction;

  final LedgerJournal journal;

  // True when the bridge found an existing journal for the same operation
  // instead of creating a duplicate.
  final bool wasAlreadyJournalized;
}
