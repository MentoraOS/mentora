import 'financial_pipeline_event.dart';

final class PipelineStartedEvent extends FinancialPipelineEvent {
  const PipelineStartedEvent({
    required super.pipelineId,
    required super.occurredAt,
  });
}
