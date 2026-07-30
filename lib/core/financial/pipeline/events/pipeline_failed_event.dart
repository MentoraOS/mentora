import 'financial_pipeline_event.dart';

final class PipelineFailedEvent extends FinancialPipelineEvent {
  const PipelineFailedEvent({
    required super.pipelineId,
    required super.occurredAt,
    required this.stepId,
    required this.executedSteps,
    required this.duration,
    required this.failedStepDuration,
    required this.error,
    required this.stackTrace,
  });

  final String stepId;

  /// Number of steps successfully completed before the failure.
  final int executedSteps;

  /// Total pipeline duration until the failure.
  final Duration duration;

  /// Duration consumed by the step that failed.
  final Duration failedStepDuration;

  final Object error;
  final StackTrace stackTrace;
}
