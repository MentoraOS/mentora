import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/recovery/metrics/'
    'financial_recovery_pipeline_metrics.dart';

void main() {
  group('FinancialRecoveryPipelineMetrics', () {
    test('creates an empty normalized metrics snapshot', () {
      final metrics = FinancialRecoveryPipelineMetrics.empty(
        '  settlement.partial.recovery  ',
      );

      expect(metrics.pipelineId, 'settlement.partial.recovery');

      expect(metrics.totalExecutions, 0);

      expect(metrics.successCount, 0);

      expect(metrics.failureCount, 0);

      expect(metrics.crashCount, 0);

      expect(metrics.finishedCount, 0);

      expect(metrics.retryCount, 0);

      expect(metrics.manualReviewCount, 0);

      expect(metrics.terminalFailureCount, 0);

      expect(metrics.ignoreCount, 0);

      expect(metrics.totalDuration, Duration.zero);

      expect(metrics.lastDuration, isNull);

      expect(metrics.lastStartedAt, isNull);

      expect(metrics.lastFinishedAt, isNull);

      expect(metrics.averageDuration, Duration.zero);

      expect(metrics.inProgressCount, 0);

      expect(metrics.controlledOutcomeCount, 0);

      expect(metrics.hasExecutions, isFalse);

      expect(metrics.hasCrashes, isFalse);

      expect(metrics.requiresManualAttention, isFalse);
    });

    test('rejects an empty pipeline identifier', () {
      expect(
        () => FinancialRecoveryPipelineMetrics.empty('   '),
        throwsArgumentError,
      );
    });

    test('calculates average duration from finished executions', () {
      const metrics = FinancialRecoveryPipelineMetrics(
        pipelineId: 'settlement.partial.recovery',
        totalExecutions: 4,
        finishedCount: 4,
        totalDuration: Duration(milliseconds: 210),
      );

      expect(metrics.averageDuration, const Duration(microseconds: 52500));
    });

    test('returns zero average when no execution has finished', () {
      const metrics = FinancialRecoveryPipelineMetrics(
        pipelineId: 'settlement.partial.recovery',
        totalExecutions: 2,
        finishedCount: 0,
        totalDuration: Duration(milliseconds: 100),
      );

      expect(metrics.averageDuration, Duration.zero);
    });

    test('calculates executions currently in progress', () {
      const metrics = FinancialRecoveryPipelineMetrics(
        pipelineId: 'settlement.partial.recovery',
        totalExecutions: 7,
        finishedCount: 5,
      );

      expect(metrics.inProgressCount, 2);
    });

    test('never exposes a negative in-progress count', () {
      const metrics = FinancialRecoveryPipelineMetrics(
        pipelineId: 'settlement.partial.recovery',
        totalExecutions: 2,
        finishedCount: 3,
      );

      expect(metrics.inProgressCount, 0);
    });

    test('calculates the number of controlled outcomes', () {
      const metrics = FinancialRecoveryPipelineMetrics(
        pipelineId: 'settlement.partial.recovery',
        successCount: 8,
        failureCount: 3,
      );

      expect(metrics.controlledOutcomeCount, 11);
    });

    test('exposes operational status flags', () {
      const metrics = FinancialRecoveryPipelineMetrics(
        pipelineId: 'settlement.partial.recovery',
        totalExecutions: 4,
        crashCount: 1,
        manualReviewCount: 2,
      );

      expect(metrics.hasExecutions, isTrue);

      expect(metrics.hasCrashes, isTrue);

      expect(metrics.requiresManualAttention, isTrue);
    });

    test('copyWith preserves unchanged values', () {
      final startedAt = DateTime.utc(2026, 7, 17, 10);

      final finishedAt = DateTime.utc(2026, 7, 17, 10, 1);

      final original = FinancialRecoveryPipelineMetrics(
        pipelineId: 'settlement.partial.recovery',
        totalExecutions: 5,
        successCount: 3,
        failureCount: 1,
        crashCount: 1,
        finishedCount: 5,
        retryCount: 1,
        manualReviewCount: 1,
        terminalFailureCount: 0,
        ignoreCount: 2,
        totalDuration: const Duration(milliseconds: 500),
        lastDuration: const Duration(milliseconds: 120),
        lastStartedAt: startedAt,
        lastFinishedAt: finishedAt,
      );

      final copy = original.copyWith(successCount: 4);

      expect(copy.pipelineId, original.pipelineId);

      expect(copy.totalExecutions, original.totalExecutions);

      expect(copy.successCount, 4);

      expect(copy.failureCount, original.failureCount);

      expect(copy.crashCount, original.crashCount);

      expect(copy.finishedCount, original.finishedCount);

      expect(copy.retryCount, original.retryCount);

      expect(copy.manualReviewCount, original.manualReviewCount);

      expect(copy.terminalFailureCount, original.terminalFailureCount);

      expect(copy.ignoreCount, original.ignoreCount);

      expect(copy.totalDuration, original.totalDuration);

      expect(copy.lastDuration, original.lastDuration);

      expect(copy.lastStartedAt, same(startedAt));

      expect(copy.lastFinishedAt, same(finishedAt));

      expect(identical(copy, original), isFalse);
    });

    test('copyWith updates every supported field', () {
      final lastStartedAt = DateTime.utc(2026, 7, 17, 12);

      final lastFinishedAt = DateTime.utc(2026, 7, 17, 12, 2);

      final metrics =
          FinancialRecoveryPipelineMetrics.empty('original.pipeline').copyWith(
            pipelineId: 'updated.pipeline',
            totalExecutions: 10,
            successCount: 5,
            failureCount: 3,
            crashCount: 2,
            finishedCount: 10,
            retryCount: 2,
            manualReviewCount: 1,
            terminalFailureCount: 1,
            ignoreCount: 4,
            totalDuration: const Duration(seconds: 20),
            lastDuration: const Duration(seconds: 3),
            lastStartedAt: lastStartedAt,
            lastFinishedAt: lastFinishedAt,
          );

      expect(metrics.pipelineId, 'updated.pipeline');

      expect(metrics.totalExecutions, 10);

      expect(metrics.successCount, 5);

      expect(metrics.failureCount, 3);

      expect(metrics.crashCount, 2);

      expect(metrics.finishedCount, 10);

      expect(metrics.retryCount, 2);

      expect(metrics.manualReviewCount, 1);

      expect(metrics.terminalFailureCount, 1);

      expect(metrics.ignoreCount, 4);

      expect(metrics.totalDuration, const Duration(seconds: 20));

      expect(metrics.lastDuration, const Duration(seconds: 3));

      expect(metrics.lastStartedAt, lastStartedAt);

      expect(metrics.lastFinishedAt, lastFinishedAt);
    });

    test('copyWith can explicitly clear optional values', () {
      final original = FinancialRecoveryPipelineMetrics(
        pipelineId: 'settlement.partial.recovery',
        lastDuration: const Duration(seconds: 2),
        lastStartedAt: DateTime.utc(2026, 7, 17, 10),
        lastFinishedAt: DateTime.utc(2026, 7, 17, 11),
      );

      final cleared = original.copyWith(
        clearLastDuration: true,
        clearLastStartedAt: true,
        clearLastFinishedAt: true,
      );

      expect(cleared.lastDuration, isNull);

      expect(cleared.lastStartedAt, isNull);

      expect(cleared.lastFinishedAt, isNull);
    });

    test('toString exposes the main operational metrics', () {
      const metrics = FinancialRecoveryPipelineMetrics(
        pipelineId: 'settlement.partial.recovery',
        totalExecutions: 3,
        successCount: 2,
        failureCount: 1,
        crashCount: 0,
        finishedCount: 3,
        retryCount: 1,
        manualReviewCount: 0,
        terminalFailureCount: 0,
        ignoreCount: 1,
        totalDuration: Duration(milliseconds: 300),
      );

      final value = metrics.toString();

      expect(
        value,
        contains(
          'pipelineId: '
          'settlement.partial.recovery',
        ),
      );

      expect(value, contains('totalExecutions: 3'));

      expect(value, contains('successCount: 2'));

      expect(value, contains('failureCount: 1'));

      expect(
        value,
        contains(
          'averageDuration: '
          '0:00:00.100000',
        ),
      );
    });
  });
}
