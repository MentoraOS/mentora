/// Base result returned after a financial pipeline execution.
///
/// A pipeline execution either completes successfully or fails.
/// Concrete result types guarantee that invalid mixed states cannot exist.
sealed class FinancialPipelineResult {
  const FinancialPipelineResult({
    required this.pipelineId,
    required this.executedSteps,
    required this.duration,
  });

  /// Identifier of the executed pipeline.
  final String pipelineId;

  /// Number of steps successfully completed.
  final int executedSteps;

  /// Total execution duration.
  final Duration duration;

  bool get isSuccess => this is FinancialPipelineSuccess;

  bool get isFailure => this is FinancialPipelineFailure;
}

/// Successful pipeline execution.
final class FinancialPipelineSuccess extends FinancialPipelineResult {
  const FinancialPipelineSuccess({
    required super.pipelineId,
    required super.executedSteps,
    required super.duration,
  });
}

/// Failed pipeline execution.
final class FinancialPipelineFailure extends FinancialPipelineResult {
  const FinancialPipelineFailure({
    required super.pipelineId,
    required super.executedSteps,
    required super.duration,
    required this.failedStepId,
    required this.error,
    required this.stackTrace,
  });

  /// Identifier of the step whose execution failed.
  final String failedStepId;

  /// Original error thrown by the failed step.
  final Object error;

  /// Original stack trace associated with the failure.
  final StackTrace stackTrace;
}
