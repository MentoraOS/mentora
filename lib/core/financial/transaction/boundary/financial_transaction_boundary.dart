import '../context/financial_transaction_context.dart';
import '../result/financial_transaction_result.dart';

/// Atomic execution boundary for financial operations.
///
/// Implementations are responsible for:
///
/// - opening a transaction;
/// - executing the supplied action;
/// - committing when the action succeeds;
/// - rolling back when the action fails;
/// - representing transaction mechanism failures explicitly.
///
/// This contract is independent from any concrete persistence provider.
abstract interface class FinancialTransactionBoundary {
  /// Executes [action] inside one financial transaction.
  ///
  /// The returned result distinguishes:
  ///
  /// - a committed transaction;
  /// - a successfully rolled-back transaction;
  /// - a transaction mechanism failure.
  Future<FinancialTransactionResult<T>> execute<T>({
    required FinancialTransactionContext context,
    required Future<T> Function() action,
  });
}
