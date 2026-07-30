import 'financial_pipeline_event.dart';

final class PipelineStepCompletedEvent extends FinancialPipelineEvent {
  const PipelineStepCompletedEvent({
    required super.pipelineId,
    required super.occurredAt,
    required this.stepId,
    required this.duration,
  });

  final String stepId;
  final Duration duration;
}
