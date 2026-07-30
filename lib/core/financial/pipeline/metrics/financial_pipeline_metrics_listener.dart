import '../events/financial_pipeline_event.dart';
import '../events/pipeline_completed_event.dart';
import '../events/pipeline_failed_event.dart';

import 'financial_pipeline_metrics_registry.dart';

/// Event listener that translates pipeline lifecycle events into metrics.
final class FinancialPipelineMetricsListener {
  const FinancialPipelineMetricsListener({
    required FinancialPipelineMetricsRegistry registry,
  }) : _registry = registry;

  final FinancialPipelineMetricsRegistry _registry;

  void call(FinancialPipelineEvent event) {
    if (event is PipelineCompletedEvent) {
      _registry.recordSuccess(
        pipelineId: event.pipelineId,
        executedSteps: event.executedSteps,
        duration: event.duration,
      );

      return;
    }

    if (event is PipelineFailedEvent) {
      _registry.recordFailure(
        pipelineId: event.pipelineId,
        executedSteps: event.executedSteps,
        duration: event.duration,
      );
    }
  }
}
