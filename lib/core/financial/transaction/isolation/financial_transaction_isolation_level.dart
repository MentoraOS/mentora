/// Isolation level requested for a financial transaction.
///
/// Concrete persistence adapters may translate these values to the closest
/// isolation level supported by their underlying database or transaction
/// provider.
enum FinancialTransactionIsolationLevel {
  /// Uses the transaction provider's default isolation level.
  platformDefault,

  /// Prevents reading uncommitted changes from concurrent transactions.
  readCommitted,

  /// Ensures repeated reads observe a stable transaction view.
  repeatableRead,

  /// Provides the strongest isolation level supported by the provider.
  serializable,
}
