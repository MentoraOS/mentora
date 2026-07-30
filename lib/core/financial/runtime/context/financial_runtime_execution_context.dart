import '../../pipeline/financial_pipeline_context.dart';

/// Immutable context describing one Financial Runtime execution.
///
/// This object wraps the existing pipeline context without modifying it.
///
/// It carries the cross-cutting information required by the Runtime:
///
/// - unique execution identity;
/// - correlation with the originating business operation;
/// - execution attempt;
/// - execution start time;
/// - immutable metadata;
/// - the concrete pipeline context.
///
/// The Runtime context contains no business logic.
final class FinancialRuntimeExecutionContext<
  TContext extends FinancialPipelineContext
> {
  FinancialRuntimeExecutionContext({
    required String executionId,
    required String correlationId,
    required this.pipelineContext,
    required DateTime startedAt,
    this.attempt = 1,
    Map<String, Object?> metadata = const {},
  }) : executionId = _requireIdentifier(
         value: executionId,
         fieldName: 'executionId',
       ),
       correlationId = _requireIdentifier(
         value: correlationId,
         fieldName: 'correlationId',
       ),
       startedAt = startedAt.toUtc(),
       metadata = Map<String, Object?>.unmodifiable(metadata) {
    if (attempt < 1) {
      throw ArgumentError.value(
        attempt,
        'attempt',
        'The execution attempt must be greater than or equal to 1.',
      );
    }
  }

  /// Unique identifier of this exact Runtime execution.
  ///
  /// A retry must receive a new execution identifier.
  final String executionId;

  /// Identifier shared by all executions belonging to the same
  /// business operation.
  ///
  /// For example, all attempts related to one consultation settlement
  /// may share the same correlation identifier.
  final String correlationId;

  /// Concrete context consumed by the existing Financial Pipeline.
  final TContext pipelineContext;

  /// UTC instant at which this Runtime execution started.
  final DateTime startedAt;

  /// Current execution attempt.
  ///
  /// The first execution uses attempt 1.
  final int attempt;

  /// Immutable cross-cutting metadata attached to the execution.
  ///
  /// Business data should remain inside [pipelineContext].
  final Map<String, Object?> metadata;

  /// Returns whether this context represents a retry.
  bool get isRetry => attempt > 1;

  /// Creates a new Runtime context for the next execution attempt.
  ///
  /// The correlation identifier and pipeline context are preserved.
  /// The caller must provide a new execution identifier and start time.
  FinancialRuntimeExecutionContext<TContext> nextAttempt({
    required String executionId,
    required DateTime startedAt,
    Map<String, Object?>? metadata,
  }) {
    return FinancialRuntimeExecutionContext<TContext>(
      executionId: executionId,
      correlationId: correlationId,
      pipelineContext: pipelineContext,
      startedAt: startedAt,
      attempt: attempt + 1,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Creates a modified copy while preserving the generic pipeline context.
  FinancialRuntimeExecutionContext<TContext> copyWith({
    String? executionId,
    String? correlationId,
    TContext? pipelineContext,
    DateTime? startedAt,
    int? attempt,
    Map<String, Object?>? metadata,
  }) {
    return FinancialRuntimeExecutionContext<TContext>(
      executionId: executionId ?? this.executionId,
      correlationId: correlationId ?? this.correlationId,
      pipelineContext: pipelineContext ?? this.pipelineContext,
      startedAt: startedAt ?? this.startedAt,
      attempt: attempt ?? this.attempt,
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
