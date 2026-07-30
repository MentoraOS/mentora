/// Mutable internal metrics accumulated for one financial pipeline.
///
/// This class belongs to the metrics infrastructure and should not be exposed
/// directly outside the registry. Consumers should receive immutable
/// FinancialPipelineMetricsSnapshot instances.
final class FinancialPipelineMetrics {
  FinancialPipelineMetrics({required this.pipelineId});

  final String pipelineId;

  int executions = 0;
  int successes = 0;
  int failures = 0;
  int executedSteps = 0;

  Duration totalDuration = Duration.zero;
  Duration? minimumDuration;
  Duration? maximumDuration;

  void recordSuccess({
    required int completedSteps,
    required Duration duration,
  }) {
    executions++;
    successes++;
    executedSteps += completedSteps;

    _recordDuration(duration);
  }

  void recordFailure({
    required int completedSteps,
    required Duration duration,
  }) {
    executions++;
    failures++;
    executedSteps += completedSteps;

    _recordDuration(duration);
  }

  void _recordDuration(Duration duration) {
    totalDuration += duration;

    final currentMinimum = minimumDuration;

    if (currentMinimum == null || duration < currentMinimum) {
      minimumDuration = duration;
    }

    final currentMaximum = maximumDuration;

    if (currentMaximum == null || duration > currentMaximum) {
      maximumDuration = duration;
    }
  }
}
