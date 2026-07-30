import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/events/'
    'financial_pipeline_event_dispatcher.dart';

import 'package:mentora/core/financial/pipeline/metrics/'
    'financial_pipeline_metrics_listener.dart';
import 'package:mentora/core/financial/pipeline/metrics/'
    'financial_pipeline_metrics_registry.dart';

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

void main() {
  group('FinancialPipelineMetricsListener', () {
    test('records successful pipeline execution', () async {
      final registry = FinancialPipelineMetricsRegistry();

      final listener = FinancialPipelineMetricsListener(registry: registry);

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

      final snapshot = registry.snapshotFor('settlement');

      expect(snapshot, isNotNull);
      expect(snapshot!.executions, 1);
      expect(snapshot.successes, 1);
      expect(snapshot.failures, 0);
      expect(snapshot.executedSteps, 2);
      expect(snapshot.successRate, 1);
      expect(snapshot.failureRate, 0);
      expect(snapshot.minimumDuration, isNotNull);
      expect(snapshot.maximumDuration, isNotNull);
    });

    test('records failed pipeline execution', () async {
      final registry = FinancialPipelineMetricsRegistry();

      final listener = FinancialPipelineMetricsListener(registry: registry);

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

      final snapshot = registry.snapshotFor('settlement');

      expect(snapshot, isNotNull);
      expect(snapshot!.executions, 1);
      expect(snapshot.successes, 0);
      expect(snapshot.failures, 1);
      expect(snapshot.executedSteps, 1);
      expect(snapshot.successRate, 0);
      expect(snapshot.failureRate, 1);
    });

    test('aggregates multiple executions', () async {
      final registry = FinancialPipelineMetricsRegistry();

      final listener = FinancialPipelineMetricsListener(registry: registry);

      final dispatcher = FinancialPipelineEventDispatcher(
        listeners: [listener.call],
      );

      final engine = DefaultFinancialPipelineEngine(
        eventDispatcher: dispatcher,
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
          steps: const [_FailingStep(id: 'step-1')],
        ),
        context: _TestContext(),
      );

      final snapshot = registry.snapshotFor('settlement');

      expect(snapshot, isNotNull);
      expect(snapshot!.executions, 2);
      expect(snapshot.successes, 1);
      expect(snapshot.failures, 1);
      expect(snapshot.executedSteps, 1);
      expect(snapshot.successRate, 0.5);
      expect(snapshot.failureRate, 0.5);
    });

    test('keeps metrics separated by pipeline id', () async {
      final registry = FinancialPipelineMetricsRegistry();

      final listener = FinancialPipelineMetricsListener(registry: registry);

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
          id: 'refund',
          steps: const [
            _SuccessfulStep(id: 'step-1'),
            _SuccessfulStep(id: 'step-2'),
          ],
        ),
        context: _TestContext(),
      );

      final settlement = registry.snapshotFor('settlement');

      final refund = registry.snapshotFor('refund');

      expect(settlement!.executions, 1);
      expect(settlement.executedSteps, 1);

      expect(refund!.executions, 1);
      expect(refund.executedSteps, 2);

      expect(registry.snapshots(), hasLength(2));
    });

    test('can reset pipeline metrics', () {
      final registry = FinancialPipelineMetricsRegistry();

      registry.recordSuccess(
        pipelineId: 'settlement',
        executedSteps: 4,
        duration: const Duration(milliseconds: 100),
      );

      expect(registry.snapshotFor('settlement'), isNotNull);

      registry.resetPipeline('settlement');

      expect(registry.snapshotFor('settlement'), isNull);
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
    throw StateError('Simulated pipeline failure');
  }
}
