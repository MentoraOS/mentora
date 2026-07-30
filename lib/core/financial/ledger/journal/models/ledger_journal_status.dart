// Lifecycle status of a ledger journal.
//
// The status represents the accounting state of the journal,
// independently from the business operation that produced it.
enum LedgerJournalStatus {
  // The journal has been created but has not yet been posted.
  pending,

  // The journal has been successfully posted to the ledger.
  posted,

  // The journal has been reversed by another accounting journal.
  reversed,

  // The journal was cancelled before being posted.
  cancelled,
}
