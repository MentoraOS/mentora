import '../isolation/financial_transaction_isolation_level.dart';

/// Immutable context describing one financial transaction.
///
/// The context carries transaction-level, execution-level and
/// correlation-level identities without containing persistence logic.
///
/// It is independent from any concrete database implementation.
final class FinancialTransactionContext {
  FinancialTransactionContext({
    required String transactionId,
    required String executionId,
    required String correlationId,
    required DateTime startedAt,
    this.isolationLevel = FinancialTransactionIsolationLevel.platformDefault,
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
       metadata = Map<String, Object?>.unmodifiable(metadata);

  /// Unique identifier of this exact transaction.
  ///
  /// A retry must normally use a new transaction identifier.
  final String transactionId;

  /// Identifier of the Runtime execution that opened this transaction.
  final String executionId;

  /// Identifier shared by all executions and transactions belonging to the
  /// same business operation.
  final String correlationId;

  /// UTC instant at which the transaction was opened.
  final DateTime startedAt;

  /// Requested transaction isolation level.
  final FinancialTransactionIsolationLevel isolationLevel;

  /// Immutable cross-cutting metadata associated with the transaction.
  ///
  /// Financial business data must remain in its dedicated domain context.
  final Map<String, Object?> metadata;

  /// Creates a modified copy of this transaction context.
  FinancialTransactionContext copyWith({
    String? transactionId,
    String? executionId,
    String? correlationId,
    DateTime? startedAt,
    FinancialTransactionIsolationLevel? isolationLevel,
    Map<String, Object?>? metadata,
  }) {
    return FinancialTransactionContext(
      transactionId: transactionId ?? this.transactionId,
      executionId: executionId ?? this.executionId,
      correlationId: correlationId ?? this.correlationId,
      startedAt: startedAt ?? this.startedAt,
      isolationLevel: isolationLevel ?? this.isolationLevel,
      metadata: metadata ?? this.metadata,
    );
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
