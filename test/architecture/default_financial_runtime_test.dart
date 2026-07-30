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

import 'package:mentora/core/financial/runtime/context/'
    'financial_runtime_execution_context.dart';
import 'package:mentora/core/financial/runtime/engine/'
    'default_financial_runtime.dart';
import 'package:mentora/core/financial/runtime/result/'
    'financial_runtime_execution_result.dart';

void main() {
  group('DefaultFinancialRuntime', () {
    test(
      'should delegate execution to the pipeline engine exactly once',
      () async {
        const pipelineResult = FinancialPipelineSuccess(
          pipelineId: 'pipeline-001',
          executedSteps: 2,
          duration: Duration(milliseconds: 300),
        );

        final pipelineEngine = _RecordingFinancialPipelineEngine(
          result: pipelineResult,
        );

        final runtime = DefaultFinancialRuntime(
          pipelineEngine: pipelineEngine,
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
        );

        final pipeline = _TestFinancialPipeline();
        final pipelineContext = _TestFinancialPipelineContext();

        final executionContext =
            FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
              executionId: 'execution-001',
              correlationId: 'consultation-001',
              pipelineContext: pipelineContext,
              startedAt: DateTime.utc(2026, 7, 17, 20),
            );

        await runtime.execute(
          pipeline: pipeline,
          executionContext: executionContext,
        );

        expect(pipelineEngine.executionCount, 1);
        expect(pipelineEngine.receivedPipeline, same(pipeline));
        expect(pipelineEngine.receivedContext, same(pipelineContext));
      },
    );

    test('should return Runtime success when pipeline succeeds', () async {
      const pipelineResult = FinancialPipelineSuccess(
        pipelineId: 'consultation-settlement',
        executedSteps: 3,
        duration: Duration(milliseconds: 450),
      );

      final runtime = DefaultFinancialRuntime(
        pipelineEngine: _RecordingFinancialPipelineEngine(
          result: pipelineResult,
        ),
        clock: () => DateTime.utc(2026, 7, 17, 20, 0, 2),
      );

      final result = await runtime.execute(
        pipeline: _TestFinancialPipeline(id: 'consultation-settlement'),
        executionContext:
            FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
              executionId: 'execution-001',
              correlationId: 'consultation-001',
              pipelineContext: _TestFinancialPipelineContext(),
              startedAt: DateTime.utc(2026, 7, 17, 20),
            ),
      );

      expect(result, isA<FinancialRuntimeExecutionSuccess>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.pipelineResult, same(pipelineResult));
      expect(result.pipelineId, 'consultation-settlement');
      expect(result.executedSteps, 3);
      expect(result.pipelineDuration, const Duration(milliseconds: 450));
      expect(result.runtimeDuration, const Duration(seconds: 2));
    });

    test(
      'should return Runtime failure when pipeline returns failure',
      () async {
        final error = StateError('Ledger posting failed');
        final stackTrace = StackTrace.current;

        final pipelineResult = FinancialPipelineFailure(
          pipelineId: 'consultation-settlement',
          executedSteps: 2,
          duration: const Duration(milliseconds: 380),
          failedStepId: 'post-ledger-journal',
          error: error,
          stackTrace: stackTrace,
        );

        final runtime = DefaultFinancialRuntime(
          pipelineEngine: _RecordingFinancialPipelineEngine(
            result: pipelineResult,
          ),
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
        );

        final result = await runtime.execute(
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
        expect(result.isFailure, isTrue);
        expect(result.isSuccess, isFalse);
        expect(result.attempt, 2);
        expect(result.isRetry, isTrue);

        final failure = result as FinancialRuntimeExecutionFailure;

        expect(failure.failedStepId, 'post-ledger-journal');
        expect(failure.error, same(error));
        expect(failure.stackTrace, same(stackTrace));
        expect(failure.pipelineResult, same(pipelineResult));
      },
    );

    test(
      'should preserve execution identity and correlation identity',
      () async {
        final runtime = DefaultFinancialRuntime(
          pipelineEngine: _RecordingFinancialPipelineEngine(
            result: const FinancialPipelineSuccess(
              pipelineId: 'pipeline-001',
              executedSteps: 1,
              duration: Duration.zero,
            ),
          ),
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
        );

        final result = await runtime.execute(
          pipeline: _TestFinancialPipeline(),
          executionContext:
              FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
                executionId: 'execution-789',
                correlationId: 'booking-456',
                pipelineContext: _TestFinancialPipelineContext(),
                startedAt: DateTime.utc(2026, 7, 17, 20),
                attempt: 3,
              ),
        );

        expect(result.executionId, 'execution-789');
        expect(result.correlationId, 'booking-456');
        expect(result.attempt, 3);
        expect(result.isRetry, isTrue);
      },
    );

    test('should preserve immutable execution metadata', () async {
      final metadata = <String, Object?>{
        'source': 'settlement-workflow',
        'provider': 'paydunya',
      };

      final runtime = DefaultFinancialRuntime(
        pipelineEngine: _RecordingFinancialPipelineEngine(
          result: const FinancialPipelineSuccess(
            pipelineId: 'pipeline-001',
            executedSteps: 1,
            duration: Duration.zero,
          ),
        ),
        clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      final executionContext =
          FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
            executionId: 'execution-001',
            correlationId: 'consultation-001',
            pipelineContext: _TestFinancialPipelineContext(),
            startedAt: DateTime.utc(2026, 7, 17, 20),
            metadata: metadata,
          );

      final result = await runtime.execute(
        pipeline: _TestFinancialPipeline(),
        executionContext: executionContext,
      );

      metadata['provider'] = 'modified';

      expect(result.metadata['source'], 'settlement-workflow');
      expect(result.metadata['provider'], 'paydunya');

      expect(
        () => result.metadata['new-key'] = 'new-value',
        throwsUnsupportedError,
      );
    });

    test('should use the injected clock as completion time', () async {
      final completionTime = DateTime(2026, 7, 17, 22, 30);

      final runtime = DefaultFinancialRuntime(
        pipelineEngine: _RecordingFinancialPipelineEngine(
          result: const FinancialPipelineSuccess(
            pipelineId: 'pipeline-001',
            executedSteps: 1,
            duration: Duration.zero,
          ),
        ),
        clock: () => completionTime,
      );

      final result = await runtime.execute(
        pipeline: _TestFinancialPipeline(),
        executionContext:
            FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
              executionId: 'execution-001',
              correlationId: 'consultation-001',
              pipelineContext: _TestFinancialPipelineContext(),
              startedAt: DateTime.utc(2026, 7, 17, 20),
            ),
      );

      expect(result.completedAt.isUtc, isTrue);
      expect(result.completedAt, completionTime.toUtc());
    });

    test('should propagate unexpected pipeline engine exceptions', () async {
      final expectedError = StateError('Invalid pipeline configuration');

      final runtime = DefaultFinancialRuntime(
        pipelineEngine: _ThrowingFinancialPipelineEngine(error: expectedError),
      );

      final future = runtime.execute(
        pipeline: _TestFinancialPipeline(),
        executionContext:
            FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
              executionId: 'execution-001',
              correlationId: 'consultation-001',
              pipelineContext: _TestFinancialPipelineContext(),
              startedAt: DateTime.now().toUtc(),
            ),
      );

      await expectLater(future, throwsA(same(expectedError)));
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

final class _ThrowingFinancialPipelineEngine
    implements FinancialPipelineEngine {
  _ThrowingFinancialPipelineEngine({required this.error});

  final Object error;

  @override
  Future<FinancialPipelineResult>
  execute<TContext extends FinancialPipelineContext>({
    required FinancialPipeline<TContext> pipeline,
    required TContext context,
  }) async {
    throw error;
  }
}
