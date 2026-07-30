import 'financial_pipeline_step_metrics.dart';

/// In-memory registry containing metrics for every financial pipeline step.
///
/// Metrics are isolated by both:
/// - pipeline identifier
/// - step identifier
///
/// This prevents two pipelines containing the same step identifier from
/// sharing the same measurements.
final class FinancialPipelineStepMetricsRegistry {
  final Map<String, Map<String, FinancialPipelineStepMetrics>>
  _metricsByPipelineId = {};

  /// Records one successful execution of a pipeline step.
  void recordSuccess({
    required String pipelineId,
    required String stepId,
    required Duration duration,
  }) {
    _validateIdentifiers(pipelineId: pipelineId, stepId: stepId);

    final current = _metricsFor(pipelineId: pipelineId, stepId: stepId);

    final nextExecutions = current.executions + 1;
    final nextTotalDuration = current.totalDuration + duration;

    final nextMinimumDuration =
        current.executions == 0 || duration < current.minDuration
        ? duration
        : current.minDuration;

    final nextMaximumDuration =
        current.executions == 0 || duration > current.maxDuration
        ? duration
        : current.maxDuration;

    _store(
      pipelineId: pipelineId,
      metrics: current.copyWith(
        executions: nextExecutions,
        totalDuration: nextTotalDuration,
        minDuration: nextMinimumDuration,
        maxDuration: nextMaximumDuration,
      ),
    );
  }

  /// Records one failed execution of a pipeline step.
  ///
  /// Failed attempts are included in duration calculations because they still
  /// consume infrastructure resources and affect user-facing latency.
  void recordFailure({
    required String pipelineId,
    required String stepId,
    required Duration duration,
  }) {
    _validateIdentifiers(pipelineId: pipelineId, stepId: stepId);

    final current = _metricsFor(pipelineId: pipelineId, stepId: stepId);

    final nextExecutions = current.executions + 1;
    final nextFailures = current.failures + 1;
    final nextTotalDuration = current.totalDuration + duration;

    final nextMinimumDuration =
        current.executions == 0 || duration < current.minDuration
        ? duration
        : current.minDuration;

    final nextMaximumDuration =
        current.executions == 0 || duration > current.maxDuration
        ? duration
        : current.maxDuration;

    _store(
      pipelineId: pipelineId,
      metrics: current.copyWith(
        executions: nextExecutions,
        failures: nextFailures,
        totalDuration: nextTotalDuration,
        minDuration: nextMinimumDuration,
        maxDuration: nextMaximumDuration,
      ),
    );
  }

  /// Returns the metrics for one step in one pipeline.
  ///
  /// Returns null when no execution has been recorded.
  FinancialPipelineStepMetrics? snapshot({
    required String pipelineId,
    required String stepId,
  }) {
    final pipelineMetrics = _metricsByPipelineId[pipelineId.trim()];

    return pipelineMetrics?[stepId.trim()];
  }

  /// Returns every step metric recorded for one pipeline.
  List<FinancialPipelineStepMetrics> snapshotsForPipeline(String pipelineId) {
    final metrics = _metricsByPipelineId[pipelineId.trim()];

    if (metrics == null) {
      return const [];
    }

    final snapshots = metrics.values.toList(growable: false)
      ..sort((left, right) => left.stepId.compareTo(right.stepId));

    return List.unmodifiable(snapshots);
  }

  /// Returns every recorded metric grouped by pipeline identifier.
  Map<String, List<FinancialPipelineStepMetrics>> snapshotsAll() {
    final result = <String, List<FinancialPipelineStepMetrics>>{};

    final pipelineIds = _metricsByPipelineId.keys.toList()..sort();

    for (final pipelineId in pipelineIds) {
      result[pipelineId] = snapshotsForPipeline(pipelineId);
    }

    return Map.unmodifiable(result);
  }

  /// Removes the metrics of one step.
  void resetStep({required String pipelineId, required String stepId}) {
    final normalizedPipelineId = pipelineId.trim();
    final normalizedStepId = stepId.trim();

    final pipelineMetrics = _metricsByPipelineId[normalizedPipelineId];

    if (pipelineMetrics == null) {
      return;
    }

    pipelineMetrics.remove(normalizedStepId);

    if (pipelineMetrics.isEmpty) {
      _metricsByPipelineId.remove(normalizedPipelineId);
    }
  }

  /// Removes every step metric belonging to one pipeline.
  void resetPipeline(String pipelineId) {
    _metricsByPipelineId.remove(pipelineId.trim());
  }

  /// Removes all step metrics.
  void resetAll() {
    _metricsByPipelineId.clear();
  }

  FinancialPipelineStepMetrics _metricsFor({
    required String pipelineId,
    required String stepId,
  }) {
    final normalizedPipelineId = pipelineId.trim();
    final normalizedStepId = stepId.trim();

    final pipelineMetrics = _metricsByPipelineId.putIfAbsent(
      normalizedPipelineId,
      () => <String, FinancialPipelineStepMetrics>{},
    );

    return pipelineMetrics.putIfAbsent(
      normalizedStepId,
      () => FinancialPipelineStepMetrics(
        stepId: normalizedStepId,
        executions: 0,
        failures: 0,
        totalDuration: Duration.zero,
        minDuration: Duration.zero,
        maxDuration: Duration.zero,
      ),
    );
  }

  void _store({
    required String pipelineId,
    required FinancialPipelineStepMetrics metrics,
  }) {
    final normalizedPipelineId = pipelineId.trim();

    final pipelineMetrics = _metricsByPipelineId.putIfAbsent(
      normalizedPipelineId,
      () => <String, FinancialPipelineStepMetrics>{},
    );

    pipelineMetrics[metrics.stepId] = metrics;
  }

  void _validateIdentifiers({
    required String pipelineId,
    required String stepId,
  }) {
    if (pipelineId.trim().isEmpty) {
      throw ArgumentError.value(
        pipelineId,
        'pipelineId',
        'Pipeline identifier must not be empty.',
      );
    }

    if (stepId.trim().isEmpty) {
      throw ArgumentError.value(
        stepId,
        'stepId',
        'Step identifier must not be empty.',
      );
    }
  }
}
