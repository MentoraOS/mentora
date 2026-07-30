import '../events/financial_pipeline_event.dart';
import '../events/pipeline_failed_event.dart';
import '../events/pipeline_step_completed_event.dart';

import 'financial_pipeline_step_metrics_registry.dart';

/// Converts financial pipeline lifecycle events into step-level metrics.
///
/// This listener intentionally ignores:
/// - PipelineStartedEvent
/// - PipelineCompletedEvent
/// - PipelineStepStartedEvent
///
/// A metric is recorded only when a step reaches a terminal state:
/// successful completion or failure.
final class FinancialPipelineStepMetricsListener {
  const FinancialPipelineStepMetricsListener({
    required FinancialPipelineStepMetricsRegistry registry,
  }) : _registry = registry;

  final FinancialPipelineStepMetricsRegistry _registry;

  void call(FinancialPipelineEvent event) {
    if (event is PipelineStepCompletedEvent) {
      _registry.recordSuccess(
        pipelineId: event.pipelineId,
        stepId: event.stepId,
        duration: event.duration,
      );

      return;
    }

    if (event is PipelineFailedEvent) {
      _registry.recordFailure(
        pipelineId: event.pipelineId,
        stepId: event.stepId,
        duration: event.failedStepDuration,
      );
    }
  }
}
