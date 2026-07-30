import 'financial_pipeline_metrics.dart';
import 'financial_pipeline_metrics_snapshot.dart';

/// Central in-memory registry of financial pipeline metrics.
///
/// The registry owns mutable metric state and exposes only immutable
/// snapshots to consumers.
final class FinancialPipelineMetricsRegistry {
  final Map<String, FinancialPipelineMetrics> _metricsByPipelineId = {};

  void recordSuccess({
    required String pipelineId,
    required int executedSteps,
    required Duration duration,
  }) {
    _metricsFor(
      pipelineId,
    ).recordSuccess(completedSteps: executedSteps, duration: duration);
  }

  void recordFailure({
    required String pipelineId,
    required int executedSteps,
    required Duration duration,
  }) {
    _metricsFor(
      pipelineId,
    ).recordFailure(completedSteps: executedSteps, duration: duration);
  }

  FinancialPipelineMetricsSnapshot? snapshotFor(String pipelineId) {
    final metrics = _metricsByPipelineId[pipelineId];

    if (metrics == null) {
      return null;
    }

    return _createSnapshot(metrics);
  }

  List<FinancialPipelineMetricsSnapshot> snapshots() {
    final values = _metricsByPipelineId.values
        .map(_createSnapshot)
        .toList(growable: false);

    values.sort((left, right) => left.pipelineId.compareTo(right.pipelineId));

    return List.unmodifiable(values);
  }

  void resetPipeline(String pipelineId) {
    _metricsByPipelineId.remove(pipelineId);
  }

  void resetAll() {
    _metricsByPipelineId.clear();
  }

  FinancialPipelineMetrics _metricsFor(String pipelineId) {
    return _metricsByPipelineId.putIfAbsent(
      pipelineId,
      () => FinancialPipelineMetrics(pipelineId: pipelineId),
    );
  }

  FinancialPipelineMetricsSnapshot _createSnapshot(
    FinancialPipelineMetrics metrics,
  ) {
    return FinancialPipelineMetricsSnapshot(
      pipelineId: metrics.pipelineId,
      executions: metrics.executions,
      successes: metrics.successes,
      failures: metrics.failures,
      executedSteps: metrics.executedSteps,
      totalDuration: metrics.totalDuration,
      averageDuration: _averageDuration(
        total: metrics.totalDuration,
        executions: metrics.executions,
      ),
      minimumDuration: metrics.minimumDuration,
      maximumDuration: metrics.maximumDuration,
    );
  }

  Duration _averageDuration({
    required Duration total,
    required int executions,
  }) {
    if (executions == 0) {
      return Duration.zero;
    }

    return Duration(microseconds: total.inMicroseconds ~/ executions);
  }
}
