/// Lifecycle state of a financial transaction.
///
/// The state represents the transaction boundary itself, not the financial
/// business operation executed inside it.
enum FinancialTransactionState {
  /// The transaction has been created but has not started yet.
  idle,

  /// The transaction has been opened and is currently executing.
  active,

  /// The transaction completed successfully and its changes were committed.
  committed,

  /// The transaction action failed and its changes were rolled back.
  rolledBack,

  /// The transaction could not be completed safely.
  ///
  /// This state may later represent failures such as:
  ///
  /// - commit failure;
  /// - rollback failure;
  /// - connection loss during finalization;
  /// - provider-specific transaction errors.
  failed,
}
