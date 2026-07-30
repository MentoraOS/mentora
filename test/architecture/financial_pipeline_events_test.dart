import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/events/'
    'financial_pipeline_event.dart';
import 'package:mentora/core/financial/pipeline/events/'
    'financial_pipeline_event_dispatcher.dart';
import 'package:mentora/core/financial/pipeline/events/'
    'pipeline_completed_event.dart';
import 'package:mentora/core/financial/pipeline/events/'
    'pipeline_failed_event.dart';
import 'package:mentora/core/financial/pipeline/events/'
    'pipeline_started_event.dart';
import 'package:mentora/core/financial/pipeline/events/'
    'pipeline_step_completed_event.dart';
import 'package:mentora/core/financial/pipeline/events/'
    'pipeline_step_started_event.dart';

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
  group('Financial pipeline events', () {
    final fixedTime = DateTime.utc(2026, 7, 13, 20);

    test('emits lifecycle events in the correct order', () async {
      final events = <FinancialPipelineEvent>[];

      final dispatcher = FinancialPipelineEventDispatcher(
        listeners: [events.add],
      );

      final engine = DefaultFinancialPipelineEngine(
        eventDispatcher: dispatcher,
        clock: () => fixedTime,
      );

      final pipeline = _TestPipeline(
        id: 'settlement',
        steps: const [
          _RecordingStep(id: 'step-1'),
          _RecordingStep(id: 'step-2'),
        ],
      );

      final result = await engine.execute(
        pipeline: pipeline,
        context: _TestContext(),
      );

      expect(result, isA<FinancialPipelineSuccess>());

      expect(events, hasLength(6));

      expect(events[0], isA<PipelineStartedEvent>());
      expect(events[1], isA<PipelineStepStartedEvent>());
      expect(events[2], isA<PipelineStepCompletedEvent>());
      expect(events[3], isA<PipelineStepStartedEvent>());
      expect(events[4], isA<PipelineStepCompletedEvent>());
      expect(events[5], isA<PipelineCompletedEvent>());

      expect((events[1] as PipelineStepStartedEvent).stepId, 'step-1');

      expect((events[2] as PipelineStepCompletedEvent).stepId, 'step-1');

      expect((events[3] as PipelineStepStartedEvent).stepId, 'step-2');

      expect((events[4] as PipelineStepCompletedEvent).stepId, 'step-2');

      final completed = events[5] as PipelineCompletedEvent;

      expect(completed.pipelineId, 'settlement');
      expect(completed.executedSteps, 2);
      expect(completed.occurredAt, fixedTime);
    });

    test('emits a failed event and stops the lifecycle', () async {
      final events = <FinancialPipelineEvent>[];

      final engine = DefaultFinancialPipelineEngine(
        eventDispatcher: FinancialPipelineEventDispatcher(
          listeners: [events.add],
        ),
        clock: () => fixedTime,
      );

      final pipeline = _TestPipeline(
        id: 'settlement',
        steps: const [
          _RecordingStep(id: 'step-1'),
          _FailingStep(id: 'step-2'),
          _RecordingStep(id: 'step-3'),
        ],
      );

      final result = await engine.execute(
        pipeline: pipeline,
        context: _TestContext(),
      );

      expect(result, isA<FinancialPipelineFailure>());

      expect(events, hasLength(5));

      expect(events[0], isA<PipelineStartedEvent>());
      expect(events[1], isA<PipelineStepStartedEvent>());
      expect(events[2], isA<PipelineStepCompletedEvent>());
      expect(events[3], isA<PipelineStepStartedEvent>());
      expect(events[4], isA<PipelineFailedEvent>());

      final failed = events[4] as PipelineFailedEvent;

      expect(failed.pipelineId, 'settlement');
      expect(failed.stepId, 'step-2');
      expect(failed.error, isA<StateError>());

      expect(events.whereType<PipelineCompletedEvent>(), isEmpty);
    });

    test('listener failure does not break pipeline execution', () async {
      final recordedEvents = <FinancialPipelineEvent>[];

      final dispatcher = FinancialPipelineEventDispatcher(
        listeners: [
          (_) => throw StateError('Listener failed'),
          recordedEvents.add,
        ],
      );

      final engine = DefaultFinancialPipelineEngine(
        eventDispatcher: dispatcher,
      );

      final result = await engine.execute(
        pipeline: _TestPipeline(
          id: 'settlement',
          steps: const [_RecordingStep(id: 'step-1')],
        ),
        context: _TestContext(),
      );

      expect(result, isA<FinancialPipelineSuccess>());
      expect(recordedEvents, hasLength(4));
    });
  });
}

final class _TestContext extends FinancialPipelineContext {
  _TestContext();

  final List<String> executions = [];
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

final class _RecordingStep implements FinancialPipelineStep<_TestContext> {
  const _RecordingStep({required this.id});

  @override
  final String id;

  @override
  Future<void> execute(_TestContext context) async {
    context.executions.add(id);
  }
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
