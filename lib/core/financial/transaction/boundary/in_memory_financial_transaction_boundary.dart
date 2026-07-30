import '../context/financial_transaction_context.dart';
import '../result/financial_transaction_result.dart';
import 'financial_transaction_boundary.dart';

/// Callback executed when an in-memory transaction begins.
typedef FinancialTransactionBeginCallback =
    Future<void> Function(FinancialTransactionContext context);

/// Callback executed when an in-memory transaction commits.
typedef FinancialTransactionCommitCallback =
    Future<void> Function(FinancialTransactionContext context);

/// Callback executed when an in-memory transaction rolls back.
typedef FinancialTransactionRollbackCallback =
    Future<void> Function(
      FinancialTransactionContext context,
      Object error,
      StackTrace stackTrace,
    );

/// First concrete Financial Transaction Boundary implementation.
///
/// This implementation models the complete transaction lifecycle in memory:
///
/// - begin;
/// - action execution;
/// - commit on action success;
/// - rollback on action failure;
/// - explicit commit and rollback mechanism failures.
///
/// It does not provide database-level atomicity. Concrete persistence adapters
/// will later implement the same [FinancialTransactionBoundary] contract.
final class InMemoryFinancialTransactionBoundary
    implements FinancialTransactionBoundary {
  InMemoryFinancialTransactionBoundary({
    FinancialTransactionBeginCallback? onBegin,
    FinancialTransactionCommitCallback? onCommit,
    FinancialTransactionRollbackCallback? onRollback,
    DateTime Function()? clock,
  }) : _onBegin = onBegin ?? _defaultBegin,
       _onCommit = onCommit ?? _defaultCommit,
       _onRollback = onRollback ?? _defaultRollback,
       _clock = clock ?? DateTime.now;

  final FinancialTransactionBeginCallback _onBegin;
  final FinancialTransactionCommitCallback _onCommit;
  final FinancialTransactionRollbackCallback _onRollback;
  final DateTime Function() _clock;

  final Set<String> _activeTransactionIds = <String>{};

  /// IDs of transactions currently executing inside this boundary.
  Set<String> get activeTransactionIds =>
      Set<String>.unmodifiable(_activeTransactionIds);

  /// Whether at least one transaction is currently active.
  bool get hasActiveTransactions => _activeTransactionIds.isNotEmpty;

  @override
  Future<FinancialTransactionResult<T>> execute<T>({
    required FinancialTransactionContext context,
    required Future<T> Function() action,
  }) async {
    final transactionId = context.transactionId;

    if (!_activeTransactionIds.add(transactionId)) {
      final error = StateError(
        'Transaction "$transactionId" is already active.',
      );

      return FinancialTransactionFailed<T>(
        transactionId: context.transactionId,
        executionId: context.executionId,
        correlationId: context.correlationId,
        error: error,
        stackTrace: StackTrace.current,
        startedAt: context.startedAt,
        completedAt: _completionTimeFor(context),
        metadata: context.metadata,
      );
    }

    try {
      try {
        await _onBegin(context);
      } catch (beginError, beginStackTrace) {
        return FinancialTransactionFailed<T>(
          transactionId: context.transactionId,
          executionId: context.executionId,
          correlationId: context.correlationId,
          error: beginError,
          stackTrace: beginStackTrace,
          startedAt: context.startedAt,
          completedAt: _completionTimeFor(context),
          metadata: context.metadata,
        );
      }

      T value;

      try {
        value = await action();
      } catch (actionError, actionStackTrace) {
        try {
          await _onRollback(context, actionError, actionStackTrace);

          return FinancialTransactionRolledBack<T>(
            transactionId: context.transactionId,
            executionId: context.executionId,
            correlationId: context.correlationId,
            error: actionError,
            stackTrace: actionStackTrace,
            startedAt: context.startedAt,
            completedAt: _completionTimeFor(context),
            metadata: context.metadata,
          );
        } catch (rollbackError, rollbackStackTrace) {
          return FinancialTransactionFailed<T>(
            transactionId: context.transactionId,
            executionId: context.executionId,
            correlationId: context.correlationId,
            error: rollbackError,
            stackTrace: rollbackStackTrace,
            originalError: actionError,
            originalStackTrace: actionStackTrace,
            startedAt: context.startedAt,
            completedAt: _completionTimeFor(context),
            metadata: context.metadata,
          );
        }
      }

      try {
        await _onCommit(context);

        return FinancialTransactionCommitted<T>(
          transactionId: context.transactionId,
          executionId: context.executionId,
          correlationId: context.correlationId,
          value: value,
          startedAt: context.startedAt,
          completedAt: _completionTimeFor(context),
          metadata: context.metadata,
        );
      } catch (commitError, commitStackTrace) {
        return FinancialTransactionFailed<T>(
          transactionId: context.transactionId,
          executionId: context.executionId,
          correlationId: context.correlationId,
          error: commitError,
          stackTrace: commitStackTrace,
          startedAt: context.startedAt,
          completedAt: _completionTimeFor(context),
          metadata: context.metadata,
        );
      }
    } finally {
      _activeTransactionIds.remove(transactionId);
    }
  }

  DateTime _completionTimeFor(FinancialTransactionContext context) {
    final now = _clock().toUtc();

    /*
     * A defensive safeguard for incorrectly configured clocks.
     *
     * Transaction results prohibit completion before transaction start.
     */
    if (now.isBefore(context.startedAt)) {
      return context.startedAt;
    }

    return now;
  }

  static Future<void> _defaultBegin(
    FinancialTransactionContext context,
  ) async {}

  static Future<void> _defaultCommit(
    FinancialTransactionContext context,
  ) async {}

  static Future<void> _defaultRollback(
    FinancialTransactionContext context,
    Object error,
    StackTrace stackTrace,
  ) async {}
}
