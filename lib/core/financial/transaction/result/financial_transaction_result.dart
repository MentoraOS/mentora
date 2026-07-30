import '../state/financial_transaction_state.dart';

/// Base result returned after one financial transaction execution.
///
/// A transaction result preserves:
///
/// - transaction identity;
/// - Runtime execution identity;
/// - business correlation identity;
/// - final transaction state;
/// - start and completion timestamps;
/// - immutable metadata.
///
/// The result does not depend on a concrete database implementation.
sealed class FinancialTransactionResult<T> {
  FinancialTransactionResult({
    required String transactionId,
    required String executionId,
    required String correlationId,
    required this.state,
    required DateTime startedAt,
    required DateTime completedAt,
    Map<String, Object?> metadata = const {},
  }) : transactionId = _requireIdentifier(
         value: transactionId,
         fieldName: 'transactionId',
       ),
       executionId = _requireIdentifier(
         value: executionId,
         fieldName: 'executionId',
       ),
       correlationId = _requireIdentifier(
         value: correlationId,
         fieldName: 'correlationId',
       ),
       startedAt = startedAt.toUtc(),
       completedAt = completedAt.toUtc(),
       metadata = Map<String, Object?>.unmodifiable(metadata) {
    if (this.completedAt.isBefore(this.startedAt)) {
      throw ArgumentError.value(
        completedAt,
        'completedAt',
        'The completion time must not be before the start time.',
      );
    }

    _validateFinalState(state);
  }

  /// Unique identifier of this transaction.
  final String transactionId;

  /// Runtime execution that opened this transaction.
  final String executionId;

  /// Business operation shared by related executions and transactions.
  final String correlationId;

  /// Final lifecycle state of the transaction.
  final FinancialTransactionState state;

  /// UTC instant at which the transaction started.
  final DateTime startedAt;

  /// UTC instant at which the transaction completed.
  final DateTime completedAt;

  /// Immutable cross-cutting transaction metadata.
  final Map<String, Object?> metadata;

  /// Complete duration of the transaction boundary.
  Duration get duration => completedAt.difference(startedAt);

  /// Whether the transaction committed successfully.
  bool get isCommitted => this is FinancialTransactionCommitted<T>;

  /// Whether the transaction rolled back successfully.
  bool get isRolledBack => this is FinancialTransactionRolledBack<T>;

  /// Whether the transaction finalization itself failed.
  bool get isFailed => this is FinancialTransactionFailed<T>;

  static void _validateFinalState(FinancialTransactionState state) {
    if (state == FinancialTransactionState.idle ||
        state == FinancialTransactionState.active) {
      throw ArgumentError.value(
        state,
        'state',
        'A transaction result must contain a final transaction state.',
      );
    }
  }

  static String _requireIdentifier({
    required String value,
    required String fieldName,
  }) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        'The identifier must not be empty.',
      );
    }

    return normalizedValue;
  }
}

/// Successful transaction result.
///
/// The action completed and its changes were committed.
final class FinancialTransactionCommitted<T>
    extends FinancialTransactionResult<T> {
  FinancialTransactionCommitted({
    required super.transactionId,
    required super.executionId,
    required super.correlationId,
    required this.value,
    required super.startedAt,
    required super.completedAt,
    super.metadata,
  }) : super(state: FinancialTransactionState.committed);

  /// Value returned by the action executed inside the transaction.
  final T value;
}

/// Rolled-back transaction result.
///
/// The transaction action failed, but rollback completed successfully.
final class FinancialTransactionRolledBack<T>
    extends FinancialTransactionResult<T> {
  FinancialTransactionRolledBack({
    required super.transactionId,
    required super.executionId,
    required super.correlationId,
    required this.error,
    required this.stackTrace,
    required super.startedAt,
    required super.completedAt,
    super.metadata,
  }) : super(state: FinancialTransactionState.rolledBack);

  /// Original error thrown by the transaction action.
  final Object error;

  /// Original stack trace associated with the action failure.
  final StackTrace stackTrace;
}

/// Failed transaction finalization.
///
/// This result represents a failure of the transaction mechanism itself,
/// such as a commit or rollback failure.
final class FinancialTransactionFailed<T>
    extends FinancialTransactionResult<T> {
  FinancialTransactionFailed({
    required super.transactionId,
    required super.executionId,
    required super.correlationId,
    required this.error,
    required this.stackTrace,
    this.originalError,
    this.originalStackTrace,
    required super.startedAt,
    required super.completedAt,
    super.metadata,
  }) : super(state: FinancialTransactionState.failed);

  /// Error produced by the transaction provider or finalization mechanism.
  final Object error;

  /// Stack trace associated with the transaction failure.
  final StackTrace stackTrace;

  /// Optional original action error.
  ///
  /// This is useful when rollback fails after the transaction action has
  /// already thrown an error.
  final Object? originalError;

  /// Optional stack trace of the original action failure.
  final StackTrace? originalStackTrace;
}
