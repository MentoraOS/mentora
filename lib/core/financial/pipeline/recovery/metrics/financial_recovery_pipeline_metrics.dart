/// Immutable operational metrics for one Financial Recovery Pipeline.
///
/// A metrics snapshot is identified by a [pipelineId] and accumulates:
///
/// - executions started;
/// - successful strategy outcomes;
/// - controlled failure outcomes;
/// - unexpected technical crashes;
/// - completed executions;
/// - decisions requiring retry or manual intervention;
/// - execution durations.
///
/// This model contains no event-listening or persistence logic.
final class FinancialRecoveryPipelineMetrics {
  const FinancialRecoveryPipelineMetrics({
    required this.pipelineId,
    this.totalExecutions = 0,
    this.successCount = 0,
    this.failureCount = 0,
    this.crashCount = 0,
    this.finishedCount = 0,
    this.retryCount = 0,
    this.manualReviewCount = 0,
    this.terminalFailureCount = 0,
    this.ignoreCount = 0,
    this.totalDuration = Duration.zero,
    this.lastDuration,
    this.lastStartedAt,
    this.lastFinishedAt,
  }) : assert(pipelineId != ''),
       assert(totalExecutions >= 0),
       assert(successCount >= 0),
       assert(failureCount >= 0),
       assert(crashCount >= 0),
       assert(finishedCount >= 0),
       assert(retryCount >= 0),
       assert(manualReviewCount >= 0),
       assert(terminalFailureCount >= 0),
       assert(ignoreCount >= 0);

  /// Recovery pipeline identifier.
  final String pipelineId;

  /// Number of executions that emitted a started event.
  final int totalExecutions;

  /// Number of controlled successful strategy results.
  final int successCount;

  /// Number of controlled failure strategy results.
  ///
  /// These are valid business outcomes such as:
  /// - retry;
  /// - manual review;
  /// - terminal failure.
  final int failureCount;

  /// Number of unexpected technical exceptions.
  final int crashCount;

  /// Number of executions that emitted a finished event.
  final int finishedCount;

  /// Number of recovery decisions requesting another attempt.
  final int retryCount;

  /// Number of recovery decisions requiring operator intervention.
  final int manualReviewCount;

  /// Number of recovery decisions marked as terminal failures.
  final int terminalFailureCount;

  /// Number of recovery decisions that required no further action.
  final int ignoreCount;

  /// Sum of all finished execution durations.
  final Duration totalDuration;

  /// Duration of the most recently finished execution.
  final Duration? lastDuration;

  /// Timestamp of the most recent started event.
  final DateTime? lastStartedAt;

  /// Timestamp of the most recent finished event.
  final DateTime? lastFinishedAt;

  /// Average duration of completed executions.
  Duration get averageDuration {
    if (finishedCount == 0) {
      return Duration.zero;
    }

    return Duration(
      microseconds: totalDuration.inMicroseconds ~/ finishedCount,
    );
  }

  /// Number of executions currently started but not yet finished.
  int get inProgressCount {
    final inProgress = totalExecutions - finishedCount;

    return inProgress < 0 ? 0 : inProgress;
  }

  /// Number of executions producing a controlled outcome.
  int get controlledOutcomeCount {
    return successCount + failureCount;
  }

  /// Whether at least one execution has been recorded.
  bool get hasExecutions {
    return totalExecutions > 0;
  }

  /// Whether at least one technical crash has occurred.
  bool get hasCrashes {
    return crashCount > 0;
  }

  /// Whether at least one case requires manual review.
  bool get requiresManualAttention {
    return manualReviewCount > 0;
  }

  FinancialRecoveryPipelineMetrics copyWith({
    String? pipelineId,
    int? totalExecutions,
    int? successCount,
    int? failureCount,
    int? crashCount,
    int? finishedCount,
    int? retryCount,
    int? manualReviewCount,
    int? terminalFailureCount,
    int? ignoreCount,
    Duration? totalDuration,
    Duration? lastDuration,
    bool clearLastDuration = false,
    DateTime? lastStartedAt,
    bool clearLastStartedAt = false,
    DateTime? lastFinishedAt,
    bool clearLastFinishedAt = false,
  }) {
    return FinancialRecoveryPipelineMetrics(
      pipelineId: pipelineId ?? this.pipelineId,
      totalExecutions: totalExecutions ?? this.totalExecutions,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      crashCount: crashCount ?? this.crashCount,
      finishedCount: finishedCount ?? this.finishedCount,
      retryCount: retryCount ?? this.retryCount,
      manualReviewCount: manualReviewCount ?? this.manualReviewCount,
      terminalFailureCount: terminalFailureCount ?? this.terminalFailureCount,
      ignoreCount: ignoreCount ?? this.ignoreCount,
      totalDuration: totalDuration ?? this.totalDuration,
      lastDuration: clearLastDuration
          ? null
          : lastDuration ?? this.lastDuration,
      lastStartedAt: clearLastStartedAt
          ? null
          : lastStartedAt ?? this.lastStartedAt,
      lastFinishedAt: clearLastFinishedAt
          ? null
          : lastFinishedAt ?? this.lastFinishedAt,
    );
  }

  /// Empty metrics snapshot for [pipelineId].
  factory FinancialRecoveryPipelineMetrics.empty(String pipelineId) {
    final normalizedPipelineId = pipelineId.trim();

    if (normalizedPipelineId.isEmpty) {
      throw ArgumentError.value(
        pipelineId,
        'pipelineId',
        'pipelineId cannot be empty.',
      );
    }

    return FinancialRecoveryPipelineMetrics(pipelineId: normalizedPipelineId);
  }

  @override
  String toString() {
    return 'FinancialRecoveryPipelineMetrics('
        'pipelineId: $pipelineId, '
        'totalExecutions: $totalExecutions, '
        'successCount: $successCount, '
        'failureCount: $failureCount, '
        'crashCount: $crashCount, '
        'finishedCount: $finishedCount, '
        'retryCount: $retryCount, '
        'manualReviewCount: $manualReviewCount, '
        'terminalFailureCount: $terminalFailureCount, '
        'ignoreCount: $ignoreCount, '
        'totalDuration: $totalDuration, '
        'averageDuration: $averageDuration'
        ')';
  }
}
