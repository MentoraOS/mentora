import 'financial_pipeline_event.dart';

final class PipelineStepStartedEvent extends FinancialPipelineEvent {
  const PipelineStepStartedEvent({
    required super.pipelineId,
    required super.occurredAt,
    required this.stepId,
  });

  final String stepId;
}
