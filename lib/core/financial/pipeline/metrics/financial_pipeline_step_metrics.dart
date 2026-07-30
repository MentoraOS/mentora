/// Immutable metrics snapshot for one step inside a financial pipeline.
final class FinancialPipelineStepMetrics {
  const FinancialPipelineStepMetrics({
    required this.stepId,
    required this.executions,
    required this.failures,
    required this.totalDuration,
    required this.minDuration,
    required this.maxDuration,
  });

  /// Stable identifier of the measured step.
  final String stepId;

  /// Total number of completed attempts, including failures.
  final int executions;

  /// Number of failed attempts.
  final int failures;

  /// Total duration accumulated across all attempts.
  final Duration totalDuration;

  /// Shortest recorded attempt.
  final Duration minDuration;

  /// Longest recorded attempt.
  final Duration maxDuration;

  /// Number of successful executions.
  int get successes => executions - failures;

  /// Average duration across successful and failed attempts.
  Duration get averageDuration {
    if (executions == 0) {
      return Duration.zero;
    }

    return Duration(microseconds: totalDuration.inMicroseconds ~/ executions);
  }

  /// Success ratio between 0 and 1.
  double get successRate {
    if (executions == 0) {
      return 0;
    }

    return successes / executions;
  }

  /// Failure ratio between 0 and 1.
  double get failureRate {
    if (executions == 0) {
      return 0;
    }

    return failures / executions;
  }

  FinancialPipelineStepMetrics copyWith({
    String? stepId,
    int? executions,
    int? failures,
    Duration? totalDuration,
    Duration? minDuration,
    Duration? maxDuration,
  }) {
    return FinancialPipelineStepMetrics(
      stepId: stepId ?? this.stepId,
      executions: executions ?? this.executions,
      failures: failures ?? this.failures,
      totalDuration: totalDuration ?? this.totalDuration,
      minDuration: minDuration ?? this.minDuration,
      maxDuration: maxDuration ?? this.maxDuration,
    );
  }
}
