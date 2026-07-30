import 'financial_pipeline_event.dart';

final class PipelineCompletedEvent extends FinancialPipelineEvent {
  const PipelineCompletedEvent({
    required super.pipelineId,
    required super.occurredAt,
    required this.executedSteps,
    required this.duration,
  });

  final int executedSteps;

  final Duration duration;
}
