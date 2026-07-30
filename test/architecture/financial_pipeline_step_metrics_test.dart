import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/'
    'default_financial_pipeline_engine.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_result.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_step.dart';

import 'package:mentora/core/financial/pipeline/events/'
    'financial_pipeline_event_dispatcher.dart';

import 'package:mentora/core/financial/pipeline/metrics/'
    'financial_pipeline_step_metrics_listener.dart';
import 'package:mentora/core/financial/pipeline/metrics/'
    'financial_pipeline_step_metrics_registry.dart';

void main() {
  group('FinancialPipelineStepMetricsRegistry', () {
    test('records a successful step execution', () {
      final registry = FinancialPipelineStepMetricsRegistry();

      registry.recordSuccess(
        pipelineId: 'settlement',
        stepId: 'post-ledger',
        duration: const Duration(milliseconds: 100),
      );

      final snapshot = registry.snapshot(
        pipelineId: 'settlement',
        stepId: 'post-ledger',
      );

      expect(snapshot, isNotNull);
      expect(snapshot!.stepId, 'post-ledger');
      expect(snapshot.executions, 1);
      expect(snapshot.successes, 1);
      expect(snapshot.failures, 0);
      expect(snapshot.totalDuration, const Duration(milliseconds: 100));
      expect(snapshot.averageDuration, const Duration(milliseconds: 100));
      expect(snapshot.minDuration, const Duration(milliseconds: 100));
      expect(snapshot.maxDuration, const Duration(milliseconds: 100));
      expect(snapshot.successRate, 1);
      expect(snapshot.failureRate, 0);
    });

    test('records a failed step execution', () {
      final registry = FinancialPipelineStepMetricsRegistry();

      registry.recordFailure(
        pipelineId: 'settlement',
        stepId: 'post-ledger',
        duration: const Duration(milliseconds: 80),
      );

      final snapshot = registry.snapshot(
        pipelineId: 'settlement',
        stepId: 'post-ledger',
      );

      expect(snapshot, isNotNull);
      expect(snapshot!.executions, 1);
      expect(snapshot.successes, 0);
      expect(snapshot.failures, 1);
      expect(snapshot.totalDuration, const Duration(milliseconds: 80));
      expect(snapshot.averageDuration, const Duration(milliseconds: 80));
      expect(snapshot.minDuration, const Duration(milliseconds: 80));
      expect(snapshot.maxDuration, const Duration(milliseconds: 80));
      expect(snapshot.successRate, 0);
      expect(snapshot.failureRate, 1);
    });

    test('aggregates successful and failed attempts', () {
      final registry = FinancialPipelineStepMetricsRegistry();

      registry.recordSuccess(
        pipelineId: 'settlement',
        stepId: 'post-ledger',
        duration: const Duration(milliseconds: 40),
      );

      registry.recordFailure(
        pipelineId: 'settlement',
        stepId: 'post-ledger',
        duration: const Duration(milliseconds: 100),
      );

      registry.recordSuccess(
        pipelineId: 'settlement',
        stepId: 'post-ledger',
        duration: const Duration(milliseconds: 70),
      );

      final snapshot = registry.snapshot(
        pipelineId: 'settlement',
        stepId: 'post-ledger',
      );

      expect(snapshot, isNotNull);
      expect(snapshot!.executions, 3);
      expect(snapshot.successes, 2);
      expect(snapshot.failures, 1);
      expect(snapshot.totalDuration, const Duration(milliseconds: 210));
      expect(snapshot.averageDuration, const Duration(milliseconds: 70));
      expect(snapshot.minDuration, const Duration(milliseconds: 40));
      expect(snapshot.maxDuration, const Duration(milliseconds: 100));
      expect(snapshot.successRate, closeTo(2 / 3, 0.0001));
      expect(snapshot.failureRate, closeTo(1 / 3, 0.0001));
    });

    test('isolates metrics by pipeline id', () {
      final registry = FinancialPipelineStepMetricsRegistry();

      registry.recordSuccess(
        pipelineId: 'settlement',
        stepId: 'validate-input',
        duration: const Duration(milliseconds: 10),
      );

      registry.recordFailure(
        pipelineId: 'refund',
        stepId: 'validate-input',
        duration: const Duration(milliseconds: 30),
      );

      final settlement = registry.snapshot(
        pipelineId: 'settlement',
        stepId: 'validate-input',
      );

      final refund = registry.snapshot(
        pipelineId: 'refund',
        stepId: 'validate-input',
      );

      expect(settlement, isNotNull);
      expect(settlement!.executions, 1);
      expect(settlement.failures, 0);

      expect(refund, isNotNull);
      expect(refund!.executions, 1);
      expect(refund.failures, 1);
    });

    test('returns sorted snapshots for one pipeline', () {
      final registry = FinancialPipelineStepMetricsRegistry();

      registry.recordSuccess(
        pipelineId: 'settlement',
        stepId: 'step-c',
        duration: const Duration(milliseconds: 30),
      );

      registry.recordSuccess(
        pipelineId: 'settlement',
        stepId: 'step-a',
        duration: const Duration(milliseconds: 10),
      );

      registry.recordSuccess(
        pipelineId: 'settlement',
        stepId: 'step-b',
        duration: const Duration(milliseconds: 20),
      );

      final snapshots = registry.snapshotsForPipeline('settlement');

      expect(snapshots.map((metrics) => metrics.stepId), [
        'step-a',
        'step-b',
        'step-c',
      ]);
    });

    test('returns all metrics grouped by pipeline id', () {
      final registry = FinancialPipelineStepMetricsRegistry();

      registry.recordSuccess(
        pipelineId: 'settlement',
        stepId: 'step-1',
        duration: const Duration(milliseconds: 10),
      );

      registry.recordSuccess(
        pipelineId: 'refund',
        stepId: 'step-1',
        duration: const Duration(milliseconds: 20),
      );

      final snapshots = registry.snapshotsAll();

      expect(snapshots.keys, ['refund', 'settlement']);
      expect(snapshots['refund'], hasLength(1));
      expect(snapshots['settlement'], hasLength(1));
    });

    test('resets one step only', () {
      final registry = FinancialPipelineStepMetricsRegistry();

      registry.recordSuccess(
        pipelineId: 'settlement',
        stepId: 'step-1',
        duration: const Duration(milliseconds: 10),
      );

      registry.recordSuccess(
        pipelineId: 'settlement',
        stepId: 'step-2',
        duration: const Duration(milliseconds: 20),
      );

      registry.resetStep(pipelineId: 'settlement', stepId: 'step-1');

      expect(
        registry.snapshot(pipelineId: 'settlement', stepId: 'step-1'),
        isNull,
      );

      expect(
        registry.snapshot(pipelineId: 'settlement', stepId: 'step-2'),
        isNotNull,
      );
    });

    test('resets all steps for one pipeline', () {
      final registry = FinancialPipelineStepMetricsRegistry();

      registry.recordSuccess(
        pipelineId: 'settlement',
        stepId: 'step-1',
        duration: const Duration(milliseconds: 10),
      );

      registry.recordSuccess(
        pipelineId: 'refund',
        stepId: 'step-1',
        duration: const Duration(milliseconds: 20),
      );

      registry.resetPipeline('settlement');

      expect(registry.snapshotsForPipeline('settlement'), isEmpty);

      expect(registry.snapshotsForPipeline('refund'), isNotEmpty);
    });

    test('resets all metrics', () {
      final registry = FinancialPipelineStepMetricsRegistry();

      registry.recordSuccess(
        pipelineId: 'settlement',
        stepId: 'step-1',
        duration: const Duration(milliseconds: 10),
      );

      registry.recordSuccess(
        pipelineId: 'refund',
        stepId: 'step-1',
        duration: const Duration(milliseconds: 20),
      );

      registry.resetAll();

      expect(registry.snapshotsAll(), isEmpty);
    });

    test('rejects an empty pipeline id', () {
      final registry = FinancialPipelineStepMetricsRegistry();

      expect(
        () => registry.recordSuccess(
          pipelineId: ' ',
          stepId: 'step-1',
          duration: Duration.zero,
        ),
        throwsArgumentError,
      );
    });

    test('rejects an empty step id', () {
      final registry = FinancialPipelineStepMetricsRegistry();

      expect(
        () => registry.recordSuccess(
          pipelineId: 'settlement',
          stepId: ' ',
          duration: Duration.zero,
        ),
        throwsArgumentError,
      );
    });
  });

  group('FinancialPipelineStepMetricsListener', () {
    test('records each successful step executed by the engine', () async {
      final registry = FinancialPipelineStepMetricsRegistry();

      final listener = FinancialPipelineStepMetricsListener(registry: registry);

      final engine = DefaultFinancialPipelineEngine(
        eventDispatcher: FinancialPipelineEventDispatcher(
          listeners: [listener.call],
        ),
      );

      final result = await engine.execute(
        pipeline: _TestPipeline(
          id: 'settlement',
          steps: const [
            _SuccessfulStep(id: 'step-1'),
            _SuccessfulStep(id: 'step-2'),
          ],
        ),
        context: _TestContext(),
      );

      expect(result, isA<FinancialPipelineSuccess>());

      final first = registry.snapshot(
        pipelineId: 'settlement',
        stepId: 'step-1',
      );

      final second = registry.snapshot(
        pipelineId: 'settlement',
        stepId: 'step-2',
      );

      expect(first, isNotNull);
      expect(first!.executions, 1);
      expect(first.failures, 0);

      expect(second, isNotNull);
      expect(second!.executions, 1);
      expect(second.failures, 0);
    });

    test('records a failed step and preserves prior successes', () async {
      final registry = FinancialPipelineStepMetricsRegistry();

      final listener = FinancialPipelineStepMetricsListener(registry: registry);

      final engine = DefaultFinancialPipelineEngine(
        eventDispatcher: FinancialPipelineEventDispatcher(
          listeners: [listener.call],
        ),
      );

      final result = await engine.execute(
        pipeline: _TestPipeline(
          id: 'settlement',
          steps: const [
            _SuccessfulStep(id: 'step-1'),
            _FailingStep(id: 'step-2'),
            _SuccessfulStep(id: 'step-3'),
          ],
        ),
        context: _TestContext(),
      );

      expect(result, isA<FinancialPipelineFailure>());

      final first = registry.snapshot(
        pipelineId: 'settlement',
        stepId: 'step-1',
      );

      final second = registry.snapshot(
        pipelineId: 'settlement',
        stepId: 'step-2',
      );

      final third = registry.snapshot(
        pipelineId: 'settlement',
        stepId: 'step-3',
      );

      expect(first, isNotNull);
      expect(first!.executions, 1);
      expect(first.failures, 0);

      expect(second, isNotNull);
      expect(second!.executions, 1);
      expect(second.failures, 1);

      expect(third, isNull);
    });

    test('aggregates repeated executions of the same pipeline', () async {
      final registry = FinancialPipelineStepMetricsRegistry();

      final listener = FinancialPipelineStepMetricsListener(registry: registry);

      final engine = DefaultFinancialPipelineEngine(
        eventDispatcher: FinancialPipelineEventDispatcher(
          listeners: [listener.call],
        ),
      );

      await engine.execute(
        pipeline: _TestPipeline(
          id: 'settlement',
          steps: const [_SuccessfulStep(id: 'step-1')],
        ),
        context: _TestContext(),
      );

      await engine.execute(
        pipeline: _TestPipeline(
          id: 'settlement',
          steps: const [_SuccessfulStep(id: 'step-1')],
        ),
        context: _TestContext(),
      );

      final snapshot = registry.snapshot(
        pipelineId: 'settlement',
        stepId: 'step-1',
      );

      expect(snapshot, isNotNull);
      expect(snapshot!.executions, 2);
      expect(snapshot.successes, 2);
      expect(snapshot.failures, 0);
    });

    test('does not mix identical step ids across pipelines', () async {
      final registry = FinancialPipelineStepMetricsRegistry();

      final listener = FinancialPipelineStepMetricsListener(registry: registry);

      final engine = DefaultFinancialPipelineEngine(
        eventDispatcher: FinancialPipelineEventDispatcher(
          listeners: [listener.call],
        ),
      );

      await engine.execute(
        pipeline: _TestPipeline(
          id: 'settlement',
          steps: const [_SuccessfulStep(id: 'validate-input')],
        ),
        context: _TestContext(),
      );

      await engine.execute(
        pipeline: _TestPipeline(
          id: 'refund',
          steps: const [_FailingStep(id: 'validate-input')],
        ),
        context: _TestContext(),
      );

      final settlement = registry.snapshot(
        pipelineId: 'settlement',
        stepId: 'validate-input',
      );

      final refund = registry.snapshot(
        pipelineId: 'refund',
        stepId: 'validate-input',
      );

      expect(settlement!.failures, 0);
      expect(refund!.failures, 1);
    });
  });
}

final class _TestContext extends FinancialPipelineContext {
  _TestContext();
}

final class _TestPipeline implements FinancialPipeline<_TestContext> {
  _TestPipeline({
    required this.id,
    required List<FinancialPipelineStep<_TestContext>> steps,
  }) : steps = List.unmodifiable(steps);

  @override
  final String id;

  @override
  final List<FinancialPipelineStep<_TestContext>> steps;
}

final class _SuccessfulStep implements FinancialPipelineStep<_TestContext> {
  const _SuccessfulStep({required this.id});

  @override
  final String id;

  @override
  Future<void> execute(_TestContext context) async {}
}

final class _FailingStep implements FinancialPipelineStep<_TestContext> {
  const _FailingStep({required this.id});

  @override
  final String id;

  @override
  Future<void> execute(_TestContext context) async {
    throw StateError('Simulated step failure');
  }
}
