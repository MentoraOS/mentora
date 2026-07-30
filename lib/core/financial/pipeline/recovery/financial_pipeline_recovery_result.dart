// Result produced after attempting to compensate a failed pipeline.
sealed class FinancialPipelineRecoveryResult {
  const FinancialPipelineRecoveryResult({
    required this.pipelineId,
    required this.executedCompensations,
    required this.duration,
  });

  final String pipelineId;

  // Number of compensation steps completed successfully.
  final int executedCompensations;

  final Duration duration;

  bool get isSuccess => this is FinancialPipelineRecoverySuccess;

  bool get isFailure => this is FinancialPipelineRecoveryFailure;
}

// Every requested compensation completed successfully.
final class FinancialPipelineRecoverySuccess
    extends FinancialPipelineRecoveryResult {
  const FinancialPipelineRecoverySuccess({
    required super.pipelineId,
    required super.executedCompensations,
    required super.duration,
  });
}

// Recovery stopped because one compensation failed.
final class FinancialPipelineRecoveryFailure
    extends FinancialPipelineRecoveryResult {
  const FinancialPipelineRecoveryFailure({
    required super.pipelineId,
    required super.executedCompensations,
    required super.duration,
    required this.failedCompensationId,
    required this.error,
    required this.stackTrace,
  });

  final String failedCompensationId;
  final Object error;
  final StackTrace stackTrace;
}
