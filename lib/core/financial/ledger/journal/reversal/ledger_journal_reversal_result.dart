import '../models/ledger_journal.dart';

// Result produced after building a compensating journal.
final class LedgerJournalReversalResult {
  const LedgerJournalReversalResult({
    required this.originalJournal,
    required this.reversalJournal,
  });

  final LedgerJournal originalJournal;
  final LedgerJournal reversalJournal;

  bool get isBalanced =>
      originalJournal.isBalanced && reversalJournal.isBalanced;

  String get originalJournalId => originalJournal.journalId;

  String get reversalJournalId => reversalJournal.journalId;
}
