import '../boundary/financial_transaction_boundary.dart';
import '../boundary/in_memory_financial_transaction_boundary.dart';

/// Composition root of the Financial Transaction subsystem.
///
/// The module assembles and exposes the transaction boundary used by the
/// Financial Runtime.
///
/// It contains no financial business logic.
///
/// Concrete production adapters such as PostgreSQL, Firestore or distributed
/// transaction providers may later replace the in-memory boundary without
/// changing consumers.
final class FinancialTransactionModule {
  const FinancialTransactionModule._({required this.boundary});

  /// Application-level transaction boundary.
  final FinancialTransactionBoundary boundary;

  /// Builds the default in-memory transaction subsystem.
  ///
  /// This factory is suitable for:
  ///
  /// - development;
  /// - architecture tests;
  /// - integration tests;
  /// - environments without a persistence transaction provider.
  factory FinancialTransactionModule.inMemory({
    FinancialTransactionBeginCallback? onBegin,
    FinancialTransactionCommitCallback? onCommit,
    FinancialTransactionRollbackCallback? onRollback,
    DateTime Function()? clock,
  }) {
    final boundary = InMemoryFinancialTransactionBoundary(
      onBegin: onBegin,
      onCommit: onCommit,
      onRollback: onRollback,
      clock: clock,
    );

    return FinancialTransactionModule._(boundary: boundary);
  }

  /// Assembles the module around an existing transaction boundary.
  ///
  /// The exact [boundary] instance supplied by the caller is reused.
  ///
  /// This factory will later support concrete adapters such as:
  ///
  /// - PostgreSQLFinancialTransactionBoundary;
  /// - FirestoreFinancialTransactionBoundary;
  /// - DistributedFinancialTransactionBoundary.
  factory FinancialTransactionModule.fromBoundary({
    required FinancialTransactionBoundary boundary,
  }) {
    return FinancialTransactionModule._(boundary: boundary);
  }
}
