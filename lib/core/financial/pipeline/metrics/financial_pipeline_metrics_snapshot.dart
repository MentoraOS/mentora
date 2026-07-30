/// Immutable view of the metrics collected for one financial pipeline.
final class FinancialPipelineMetricsSnapshot {
  const FinancialPipelineMetricsSnapshot({
    required this.pipelineId,
    required this.executions,
    required this.successes,
    required this.failures,
    required this.executedSteps,
    required this.totalDuration,
    required this.averageDuration,
    required this.minimumDuration,
    required this.maximumDuration,
  });

  final String pipelineId;

  final int executions;
  final int successes;
  final int failures;
  final int executedSteps;

  final Duration totalDuration;
  final Duration averageDuration;
  final Duration? minimumDuration;
  final Duration? maximumDuration;

  double get successRate {
    if (executions == 0) {
      return 0;
    }

    return successes / executions;
  }

  double get failureRate {
    if (executions == 0) {
      return 0;
    }

    return failures / executions;
  }
}
