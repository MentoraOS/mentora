import '../../pipeline/financial_pipeline_result.dart';

/// Base result returned after one Financial Runtime execution.
///
/// The Runtime result enriches pipeline execution with:
///
/// - execution identity;
/// - business correlation identity;
/// - retry attempt;
/// - Runtime timestamps;
/// - immutable metadata.
///
/// A Runtime result may represent:
///
/// - successful pipeline execution;
/// - failed pipeline execution;
/// - Runtime infrastructure failure.
sealed class FinancialRuntimeExecutionResult {
  FinancialRuntimeExecutionResult({
    required String executionId,
    required String correlationId,
    FinancialPipelineResult? pipelineResult,
    required DateTime startedAt,
    required DateTime completedAt,
    required this.attempt,
    Map<String, Object?> metadata = const {},
  }) : executionId = _requireIdentifier(
         value: executionId,
         fieldName: 'executionId',
       ),
       correlationId = _requireIdentifier(
         value: correlationId,
         fieldName: 'correlationId',
       ),
       _pipelineResult = pipelineResult,
       startedAt = startedAt.toUtc(),
       completedAt = completedAt.toUtc(),
       metadata = Map<String, Object?>.unmodifiable(metadata) {
    if (attempt < 1) {
      throw ArgumentError.value(
        attempt,
        'attempt',
        'The execution attempt must be greater than or equal to 1.',
      );
    }

    if (this.completedAt.isBefore(this.startedAt)) {
      throw ArgumentError.value(
        completedAt,
        'completedAt',
        'The completion time must not be before the start time.',
      );
    }
  }

  /// Unique identifier of this precise Runtime execution.
  final String executionId;

  /// Identifier shared by all Runtime executions belonging to the same
  /// business operation.
  final String correlationId;

  final FinancialPipelineResult? _pipelineResult;

  /// Exact result returned by the Financial Pipeline Engine.
  ///
  /// This getter throws when the Runtime infrastructure failed before any
  /// pipeline result became available.
  FinancialPipelineResult get pipelineResult {
    final result = _pipelineResult;

    if (result == null) {
      throw StateError(
        'No FinancialPipelineResult is available for this '
        'Runtime infrastructure failure.',
      );
    }

    return result;
  }

  /// Nullable access to the underlying pipeline result.
  ///
  /// Prefer this getter when handling infrastructure failures.
  FinancialPipelineResult? get pipelineResultOrNull => _pipelineResult;

  /// Whether a pipeline result is available.
  bool get hasPipelineResult => _pipelineResult != null;

  /// UTC instant at which the Runtime execution started.
  final DateTime startedAt;

  /// UTC instant at which the Runtime execution completed.
  final DateTime completedAt;

  /// Current execution attempt.
  final int attempt;

  /// Immutable cross-cutting metadata attached to the execution.
  final Map<String, Object?> metadata;

  /// Identifier of the executed pipeline.
  ///
  /// Throws when no pipeline result is available.
  String get pipelineId => pipelineResult.pipelineId;

  /// Number of pipeline steps successfully completed.
  ///
  /// Throws when no pipeline result is available.
  int get executedSteps => pipelineResult.executedSteps;

  /// Duration measured by the Financial Pipeline Engine.
  ///
  /// Throws when no pipeline result is available.
  Duration get pipelineDuration => pipelineResult.duration;

  /// Complete duration observed by the Runtime.
  Duration get runtimeDuration => completedAt.difference(startedAt);

  /// Whether this execution represents a retry.
  bool get isRetry => attempt > 1;

  /// Whether the pipeline completed successfully.
  bool get isSuccess => this is FinancialRuntimeExecutionSuccess;

  /// Whether the pipeline completed with a regular pipeline failure.
  bool get isFailure => this is FinancialRuntimeExecutionFailure;

  /// Whether the Runtime infrastructure itself failed.
  bool get isInfrastructureFailure =>
      this is FinancialRuntimeInfrastructureFailure;

  /// Creates the appropriate Runtime result from a pipeline result.
  factory FinancialRuntimeExecutionResult.fromPipelineResult({
    required String executionId,
    required String correlationId,
    required FinancialPipelineResult pipelineResult,
    required DateTime startedAt,
    required DateTime completedAt,
    required int attempt,
    Map<String, Object?> metadata = const {},
  }) {
    return switch (pipelineResult) {
      FinancialPipelineSuccess success => FinancialRuntimeExecutionSuccess(
        executionId: executionId,
        correlationId: correlationId,
        pipelineResult: success,
        startedAt: startedAt,
        completedAt: completedAt,
        attempt: attempt,
        metadata: metadata,
      ),
      FinancialPipelineFailure failure => FinancialRuntimeExecutionFailure(
        executionId: executionId,
        correlationId: correlationId,
        pipelineResult: failure,
        startedAt: startedAt,
        completedAt: completedAt,
        attempt: attempt,
        metadata: metadata,
      ),
    };
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

/// Successful Financial Runtime execution.
final class FinancialRuntimeExecutionSuccess
    extends FinancialRuntimeExecutionResult {
  FinancialRuntimeExecutionSuccess({
    required super.executionId,
    required super.correlationId,
    required FinancialPipelineSuccess pipelineResult,
    required super.startedAt,
    required super.completedAt,
    required super.attempt,
    super.metadata,
  }) : super(pipelineResult: pipelineResult);

  @override
  FinancialPipelineSuccess get pipelineResult =>
      super.pipelineResult as FinancialPipelineSuccess;

  @override
  FinancialPipelineSuccess? get pipelineResultOrNull => pipelineResult;
}

/// Failed Financial Runtime pipeline execution.
///
/// This means that the pipeline failed normally and the surrounding
/// infrastructure remained capable of representing that failure safely.
final class FinancialRuntimeExecutionFailure
    extends FinancialRuntimeExecutionResult {
  FinancialRuntimeExecutionFailure({
    required super.executionId,
    required super.correlationId,
    required FinancialPipelineFailure pipelineResult,
    required super.startedAt,
    required super.completedAt,
    required super.attempt,
    super.metadata,
  }) : super(pipelineResult: pipelineResult);

  @override
  FinancialPipelineFailure get pipelineResult =>
      super.pipelineResult as FinancialPipelineFailure;

  @override
  FinancialPipelineFailure? get pipelineResultOrNull => pipelineResult;

  /// Identifier of the pipeline step that failed.
  String get failedStepId => pipelineResult.failedStepId;

  /// Original error thrown by the failed pipeline step.
  Object get error => pipelineResult.error;

  /// Original stack trace associated with the pipeline failure.
  StackTrace get stackTrace => pipelineResult.stackTrace;
}

/// Runtime infrastructure failure.
///
/// This result represents a failure outside normal pipeline execution, such
/// as:
///
/// - transaction begin failure;
/// - transaction commit failure;
/// - transaction rollback failure;
/// - transaction provider failure;
/// - unavailable persistence infrastructure.
///
/// A pipeline result may still be available when the infrastructure fails
/// after pipeline execution, for example during commit or rollback.
final class FinancialRuntimeInfrastructureFailure
    extends FinancialRuntimeExecutionResult {
  FinancialRuntimeInfrastructureFailure({
    required super.executionId,
    required super.correlationId,
    required String transactionId,
    required this.error,
    required this.stackTrace,
    this.originalError,
    this.originalStackTrace,
    super.pipelineResult,
    required super.startedAt,
    required super.completedAt,
    required super.attempt,
    super.metadata,
  }) : transactionId = _requireTransactionIdentifier(transactionId);

  final String transactionId;
  final Object error;
  final StackTrace stackTrace;
  final Object? originalError;
  final StackTrace? originalStackTrace;

  bool get occurredAfterPipelineExecution => hasPipelineResult;

  static String _requireTransactionIdentifier(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        'transactionId',
        'The identifier must not be empty.',
      );
    }

    return normalizedValue;
  }
}
