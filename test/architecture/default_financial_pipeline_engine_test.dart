import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/'
    'default_financial_pipeline_engine.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_exception.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_result.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_step.dart';

void main() {
  group('DefaultFinancialPipelineEngine', () {
    final engine = DefaultFinancialPipelineEngine();

    test('executes every step sequentially', () async {
      final context = _TestContext();

      final pipeline = _TestPipeline(
        id: 'settlement',
        steps: [
          _RecordingStep(id: 'step-1', value: 'first'),
          _RecordingStep(id: 'step-2', value: 'second'),
          _RecordingStep(id: 'step-3', value: 'third'),
        ],
      );

      final result = await engine.execute(pipeline: pipeline, context: context);

      expect(context.executions, ['first', 'second', 'third']);

      expect(result, isA<FinancialPipelineSuccess>());

      final success = result as FinancialPipelineSuccess;

      expect(success.pipelineId, 'settlement');
      expect(success.executedSteps, 3);
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
    });

    test('stops execution when a step fails', () async {
      final context = _TestContext();

      final pipeline = _TestPipeline(
        id: 'settlement',
        steps: [
          _RecordingStep(id: 'step-1', value: 'first'),
          _FailingStep(id: 'step-2'),
          _RecordingStep(id: 'step-3', value: 'third'),
        ],
      );

      final result = await engine.execute(pipeline: pipeline, context: context);

      expect(context.executions, ['first']);

      expect(result, isA<FinancialPipelineFailure>());

      final failure = result as FinancialPipelineFailure;

      expect(failure.pipelineId, 'settlement');
      expect(failure.executedSteps, 1);
      expect(failure.failedStepId, 'step-2');
      expect(failure.error, isA<StateError>());
      expect(failure.isSuccess, isFalse);
      expect(failure.isFailure, isTrue);
    });

    test('rejects an empty pipeline id', () async {
      final pipeline = _TestPipeline(
        id: ' ',
        steps: [_RecordingStep(id: 'step-1', value: 'first')],
      );

      expect(
        () => engine.execute(pipeline: pipeline, context: _TestContext()),
        throwsA(isA<InvalidFinancialPipelineException>()),
      );
    });

    test('rejects a pipeline without steps', () async {
      final pipeline = _TestPipeline(id: 'settlement', steps: const []);

      expect(
        () => engine.execute(pipeline: pipeline, context: _TestContext()),
        throwsA(isA<InvalidFinancialPipelineException>()),
      );
    });

    test('rejects an empty step id', () async {
      final pipeline = _TestPipeline(
        id: 'settlement',
        steps: [_RecordingStep(id: ' ', value: 'first')],
      );

      expect(
        () => engine.execute(pipeline: pipeline, context: _TestContext()),
        throwsA(isA<InvalidFinancialPipelineException>()),
      );
    });

    test('rejects duplicate step ids', () async {
      final pipeline = _TestPipeline(
        id: 'settlement',
        steps: [
          _RecordingStep(id: 'duplicate', value: 'first'),
          _RecordingStep(id: 'duplicate', value: 'second'),
        ],
      );

      expect(
        () => engine.execute(pipeline: pipeline, context: _TestContext()),
        throwsA(isA<InvalidFinancialPipelineException>()),
      );
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
  const _RecordingStep({required this.id, required this.value});

  @override
  final String id;

  final String value;

  @override
  Future<void> execute(_TestContext context) async {
    context.executions.add(value);
  }
}

final class _FailingStep implements FinancialPipelineStep<_TestContext> {
  const _FailingStep({required this.id});

  @override
  final String id;

  @override
  Future<void> execute(_TestContext context) async {
    throw StateError('Simulated pipeline failure.');
  }
}
