/// Base exception for failures produced by the financial pipeline
/// infrastructure itself.
///
/// Business exceptions thrown by individual steps should remain separate and
/// are wrapped only when the infrastructure needs to add pipeline metadata.
sealed class FinancialPipelineException implements Exception {
  const FinancialPipelineException({
    required this.pipelineId,
    required this.message,
    this.cause,
    this.causeStackTrace,
  });

  final String pipelineId;
  final String message;
  final Object? cause;
  final StackTrace? causeStackTrace;

  @override
  String toString() {
    final buffer = StringBuffer(
      '$runtimeType('
      'pipelineId: $pipelineId, '
      'message: $message',
    );

    if (cause != null) {
      buffer.write(', cause: $cause');
    }

    buffer.write(')');

    return buffer.toString();
  }
}

/// Raised when a specific pipeline step cannot be executed successfully.
final class FinancialPipelineStepException extends FinancialPipelineException {
  const FinancialPipelineStepException({
    required super.pipelineId,
    required this.stepId,
    required super.message,
    super.cause,
    super.causeStackTrace,
  });

  final String stepId;

  @override
  String toString() {
    final buffer = StringBuffer(
      '$runtimeType('
      'pipelineId: $pipelineId, '
      'stepId: $stepId, '
      'message: $message',
    );

    if (cause != null) {
      buffer.write(', cause: $cause');
    }

    buffer.write(')');

    return buffer.toString();
  }
}

/// Raised when the pipeline definition itself is invalid.
final class InvalidFinancialPipelineException
    extends FinancialPipelineException {
  const InvalidFinancialPipelineException({
    required super.pipelineId,
    required super.message,
    super.cause,
    super.causeStackTrace,
  });
}
