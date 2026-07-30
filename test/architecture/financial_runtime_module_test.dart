import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_engine.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_result.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_step.dart';

import 'package:mentora/core/financial/runtime/bootstrap/'
    'financial_runtime_module.dart';
import 'package:mentora/core/financial/runtime/context/'
    'financial_runtime_execution_context.dart';
import 'package:mentora/core/financial/runtime/engine/'
    'default_financial_runtime.dart';
import 'package:mentora/core/financial/runtime/result/'
    'financial_runtime_execution_result.dart';

void main() {
  group('FinancialRuntimeModule', () {
    test('initialize should assemble the complete Runtime module', () {
      final pipelineEngine = _RecordingFinancialPipelineEngine(
        result: const FinancialPipelineSuccess(
          pipelineId: 'pipeline-001',
          executedSteps: 1,
          duration: Duration.zero,
        ),
      );

      final module = FinancialRuntimeModule.initialize(
        pipelineEngine: pipelineEngine,
      );

      expect(module.pipelineEngine, same(pipelineEngine));
      expect(module.runtime, isA<DefaultFinancialRuntime>());
    });

    test('should reuse the exact pipeline engine instance', () {
      final pipelineEngine = _RecordingFinancialPipelineEngine(
        result: const FinancialPipelineSuccess(
          pipelineId: 'pipeline-001',
          executedSteps: 1,
          duration: Duration.zero,
        ),
      );

      final module = FinancialRuntimeModule.initialize(
        pipelineEngine: pipelineEngine,
      );

      expect(identical(module.pipelineEngine, pipelineEngine), isTrue);
    });

    test('module Runtime should execute through the provided engine', () async {
      const pipelineResult = FinancialPipelineSuccess(
        pipelineId: 'consultation-settlement',
        executedSteps: 2,
        duration: Duration(milliseconds: 300),
      );

      final pipelineEngine = _RecordingFinancialPipelineEngine(
        result: pipelineResult,
      );

      final module = FinancialRuntimeModule.initialize(
        pipelineEngine: pipelineEngine,
        clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      final pipeline = _TestFinancialPipeline(id: 'consultation-settlement');

      final pipelineContext = _TestFinancialPipelineContext();

      final executionContext =
          FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
            executionId: 'execution-001',
            correlationId: 'consultation-001',
            pipelineContext: pipelineContext,
            startedAt: DateTime.utc(2026, 7, 17, 20),
          );

      final result = await module.runtime.execute(
        pipeline: pipeline,
        executionContext: executionContext,
      );

      expect(pipelineEngine.executionCount, 1);
      expect(pipelineEngine.receivedPipeline, same(pipeline));
      expect(pipelineEngine.receivedContext, same(pipelineContext));

      expect(result, isA<FinancialRuntimeExecutionSuccess>());

      expect(result.pipelineResult, same(pipelineResult));
    });

    test('module should propagate the injected clock to the Runtime', () async {
      final completionTime = DateTime(2026, 7, 17, 22, 30);

      final module = FinancialRuntimeModule.initialize(
        pipelineEngine: _RecordingFinancialPipelineEngine(
          result: const FinancialPipelineSuccess(
            pipelineId: 'pipeline-001',
            executedSteps: 1,
            duration: Duration.zero,
          ),
        ),
        clock: () => completionTime,
      );

      final result = await module.runtime.execute(
        pipeline: _TestFinancialPipeline(),
        executionContext:
            FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
              executionId: 'execution-001',
              correlationId: 'consultation-001',
              pipelineContext: _TestFinancialPipelineContext(),
              startedAt: DateTime.utc(2026, 7, 17, 20),
            ),
      );

      expect(result.completedAt, completionTime.toUtc());
    });

    test('module should preserve Runtime failure results', () async {
      final error = StateError('Posting failed');
      final stackTrace = StackTrace.current;

      final pipelineFailure = FinancialPipelineFailure(
        pipelineId: 'consultation-settlement',
        executedSteps: 1,
        duration: const Duration(milliseconds: 200),
        failedStepId: 'post-journal',
        error: error,
        stackTrace: stackTrace,
      );

      final module = FinancialRuntimeModule.initialize(
        pipelineEngine: _RecordingFinancialPipelineEngine(
          result: pipelineFailure,
        ),
        clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      final result = await module.runtime.execute(
        pipeline: _TestFinancialPipeline(id: 'consultation-settlement'),
        executionContext:
            FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
              executionId: 'execution-002',
              correlationId: 'consultation-001',
              pipelineContext: _TestFinancialPipelineContext(),
              startedAt: DateTime.utc(2026, 7, 17, 20),
              attempt: 2,
            ),
      );

      expect(result, isA<FinancialRuntimeExecutionFailure>());

      final failure = result as FinancialRuntimeExecutionFailure;

      expect(failure.failedStepId, 'post-journal');
      expect(failure.error, same(error));
      expect(failure.stackTrace, same(stackTrace));
      expect(failure.pipelineResult, same(pipelineFailure));
    });
  });
}

final class _TestFinancialPipelineContext extends FinancialPipelineContext {
  const _TestFinancialPipelineContext();
}

final class _TestFinancialPipeline
    implements FinancialPipeline<_TestFinancialPipelineContext> {
  _TestFinancialPipeline({this.id = 'pipeline-001'});

  @override
  final String id;

  @override
  List<FinancialPipelineStep<_TestFinancialPipelineContext>> get steps =>
      const [];
}

final class _RecordingFinancialPipelineEngine
    implements FinancialPipelineEngine {
  _RecordingFinancialPipelineEngine({required FinancialPipelineResult result})
    : _result = result;

  final FinancialPipelineResult _result;

  int executionCount = 0;
  Object? receivedPipeline;
  Object? receivedContext;

  @override
  Future<FinancialPipelineResult>
  execute<TContext extends FinancialPipelineContext>({
    required FinancialPipeline<TContext> pipeline,
    required TContext context,
  }) async {
    executionCount++;
    receivedPipeline = pipeline;
    receivedContext = context;

    return _result;
  }
}
