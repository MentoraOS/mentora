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
    'transactional_financial_runtime.dart';
import 'package:mentora/core/financial/runtime/result/'
    'financial_runtime_execution_result.dart';

import 'package:mentora/core/financial/transaction/boundary/'
    'financial_transaction_boundary.dart';
import 'package:mentora/core/financial/transaction/boundary/'
    'in_memory_financial_transaction_boundary.dart';
import 'package:mentora/core/financial/transaction/context/'
    'financial_transaction_context.dart';
import 'package:mentora/core/financial/transaction/result/'
    'financial_transaction_result.dart';

void main() {
  group('TransactionalFinancialRuntime', () {
    test('should execute pipeline and commit transaction on success', () async {
      final lifecycle = <String>[];

      const pipelineSuccess = FinancialPipelineSuccess(
        pipelineId: 'consultation-settlement',
        executedSteps: 3,
        duration: Duration(milliseconds: 450),
      );

      final pipelineEngine = _RecordingFinancialPipelineEngine(
        result: pipelineSuccess,
        onExecute: () {
          lifecycle.add('pipeline');
        },
      );

      final transactionBoundary = InMemoryFinancialTransactionBoundary(
        onBegin: (context) async {
          lifecycle.add('begin');
        },
        onCommit: (context) async {
          lifecycle.add('commit');
        },
        onRollback: (context, error, stackTrace) async {
          lifecycle.add('rollback');
        },
        clock: () => DateTime.utc(2026, 7, 17, 20, 0, 2),
      );

      final runtime = TransactionalFinancialRuntime(
        pipelineEngine: pipelineEngine,
        transactionBoundary: transactionBoundary,
        clock: () => DateTime.utc(2026, 7, 17, 20),
      );

      final pipeline = _TestFinancialPipeline(id: 'consultation-settlement');

      final pipelineContext = _TestFinancialPipelineContext();

      final result = await runtime.execute(
        pipeline: pipeline,
        executionContext:
            FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
              executionId: 'execution-001',
              correlationId: 'consultation-001',
              pipelineContext: pipelineContext,
              startedAt: DateTime.utc(2026, 7, 17, 20),
            ),
      );

      expect(lifecycle, ['begin', 'pipeline', 'commit']);

      expect(pipelineEngine.executionCount, 1);
      expect(pipelineEngine.receivedPipeline, same(pipeline));
      expect(pipelineEngine.receivedContext, same(pipelineContext));

      expect(result, isA<FinancialRuntimeExecutionSuccess>());

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.isInfrastructureFailure, isFalse);

      expect(result.pipelineResult, same(pipelineSuccess));

      expect(result.pipelineId, 'consultation-settlement');

      expect(result.executedSteps, 3);

      expect(result.pipelineDuration, const Duration(milliseconds: 450));

      expect(result.runtimeDuration, const Duration(seconds: 2));

      expect(transactionBoundary.hasActiveTransactions, isFalse);
    });

    test(
      'should rollback and return Runtime failure when pipeline fails',
      () async {
        final lifecycle = <String>[];

        final pipelineError = StateError('Ledger posting failed.');

        final pipelineStackTrace = StackTrace.current;

        final pipelineFailure = FinancialPipelineFailure(
          pipelineId: 'consultation-settlement',
          executedSteps: 2,
          duration: const Duration(milliseconds: 350),
          failedStepId: 'post-ledger-journal',
          error: pipelineError,
          stackTrace: pipelineStackTrace,
        );

        final pipelineEngine = _RecordingFinancialPipelineEngine(
          result: pipelineFailure,
          onExecute: () {
            lifecycle.add('pipeline');
          },
        );

        Object? rollbackSignal;

        final transactionBoundary = InMemoryFinancialTransactionBoundary(
          onBegin: (context) async {
            lifecycle.add('begin');
          },
          onCommit: (context) async {
            lifecycle.add('commit');
          },
          onRollback: (context, error, stackTrace) async {
            lifecycle.add('rollback');
            rollbackSignal = error;
          },
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
        );

        final runtime = TransactionalFinancialRuntime(
          pipelineEngine: pipelineEngine,
          transactionBoundary: transactionBoundary,
          clock: () => DateTime.utc(2026, 7, 17, 20),
        );

        final result = await runtime.execute(
          pipeline: _TestFinancialPipeline(id: 'consultation-settlement'),
          executionContext: _createExecutionContext(
            executionId: 'execution-002',
            attempt: 2,
          ),
        );

        expect(lifecycle, ['begin', 'pipeline', 'rollback']);

        expect(rollbackSignal, isNotNull);
        expect(rollbackSignal, isNot(same(pipelineError)));

        expect(result, isA<FinancialRuntimeExecutionFailure>());

        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.isInfrastructureFailure, isFalse);

        expect(result.attempt, 2);
        expect(result.isRetry, isTrue);

        final failure = result as FinancialRuntimeExecutionFailure;

        expect(failure.pipelineResult, same(pipelineFailure));

        expect(failure.failedStepId, 'post-ledger-journal');

        expect(failure.error, same(pipelineError));

        expect(failure.stackTrace, same(pipelineStackTrace));
      },
    );

    test(
      'should return infrastructure failure when transaction begin fails',
      () async {
        final beginError = StateError('Unable to begin transaction.');

        final pipelineEngine = _RecordingFinancialPipelineEngine(
          result: const FinancialPipelineSuccess(
            pipelineId: 'pipeline-001',
            executedSteps: 1,
            duration: Duration.zero,
          ),
        );

        final transactionBoundary = InMemoryFinancialTransactionBoundary(
          onBegin: (context) async {
            throw beginError;
          },
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
        );

        final runtime = TransactionalFinancialRuntime(
          pipelineEngine: pipelineEngine,
          transactionBoundary: transactionBoundary,
          clock: () => DateTime.utc(2026, 7, 17, 20),
        );

        final result = await runtime.execute(
          pipeline: _TestFinancialPipeline(),
          executionContext: _createExecutionContext(),
        );

        expect(pipelineEngine.executionCount, 0);

        expect(result, isA<FinancialRuntimeInfrastructureFailure>());

        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isFalse);
        expect(result.isInfrastructureFailure, isTrue);

        final infrastructureFailure =
            result as FinancialRuntimeInfrastructureFailure;

        expect(infrastructureFailure.error, same(beginError));

        expect(infrastructureFailure.hasPipelineResult, isFalse);

        expect(infrastructureFailure.pipelineResultOrNull, isNull);

        expect(infrastructureFailure.occurredAfterPipelineExecution, isFalse);
      },
    );

    test(
      'should preserve pipeline success when transaction commit fails',
      () async {
        const pipelineSuccess = FinancialPipelineSuccess(
          pipelineId: 'consultation-settlement',
          executedSteps: 3,
          duration: Duration(milliseconds: 500),
        );

        final commitError = StateError('Transaction commit failed.');

        final transactionBoundary = InMemoryFinancialTransactionBoundary(
          onCommit: (context) async {
            throw commitError;
          },
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
        );

        final runtime = TransactionalFinancialRuntime(
          pipelineEngine: _RecordingFinancialPipelineEngine(
            result: pipelineSuccess,
          ),
          transactionBoundary: transactionBoundary,
          clock: () => DateTime.utc(2026, 7, 17, 20),
        );

        final result = await runtime.execute(
          pipeline: _TestFinancialPipeline(id: 'consultation-settlement'),
          executionContext: _createExecutionContext(),
        );

        expect(result, isA<FinancialRuntimeInfrastructureFailure>());

        final infrastructureFailure =
            result as FinancialRuntimeInfrastructureFailure;

        expect(infrastructureFailure.error, same(commitError));

        expect(
          infrastructureFailure.pipelineResultOrNull,
          same(pipelineSuccess),
        );

        expect(infrastructureFailure.hasPipelineResult, isTrue);

        expect(infrastructureFailure.occurredAfterPipelineExecution, isTrue);

        expect(infrastructureFailure.pipelineId, 'consultation-settlement');

        expect(infrastructureFailure.originalError, isNull);

        expect(infrastructureFailure.originalStackTrace, isNull);
      },
    );

    test(
      'should preserve pipeline failure when transaction rollback fails',
      () async {
        final pipelineError = StateError('Pipeline execution failed.');

        final pipelineStackTrace = StackTrace.current;

        final pipelineFailure = FinancialPipelineFailure(
          pipelineId: 'consultation-settlement',
          executedSteps: 1,
          duration: const Duration(milliseconds: 200),
          failedStepId: 'reserve-funds',
          error: pipelineError,
          stackTrace: pipelineStackTrace,
        );

        final rollbackError = StateError('Transaction rollback failed.');

        final transactionBoundary = InMemoryFinancialTransactionBoundary(
          onRollback: (context, error, stackTrace) async {
            throw rollbackError;
          },
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
        );

        final runtime = TransactionalFinancialRuntime(
          pipelineEngine: _RecordingFinancialPipelineEngine(
            result: pipelineFailure,
          ),
          transactionBoundary: transactionBoundary,
          clock: () => DateTime.utc(2026, 7, 17, 20),
        );

        final result = await runtime.execute(
          pipeline: _TestFinancialPipeline(id: 'consultation-settlement'),
          executionContext: _createExecutionContext(),
        );

        expect(result, isA<FinancialRuntimeInfrastructureFailure>());

        final infrastructureFailure =
            result as FinancialRuntimeInfrastructureFailure;

        expect(infrastructureFailure.error, same(rollbackError));

        expect(infrastructureFailure.originalError, same(pipelineError));

        expect(
          infrastructureFailure.originalStackTrace,
          same(pipelineStackTrace),
        );

        expect(
          infrastructureFailure.pipelineResultOrNull,
          same(pipelineFailure),
        );

        expect(infrastructureFailure.pipelineId, 'consultation-settlement');

        expect(infrastructureFailure.occurredAfterPipelineExecution, isTrue);
      },
    );

    test(
      'should return infrastructure failure when pipeline engine throws',
      () async {
        final engineError = StateError('Unexpected pipeline engine exception.');

        var rollbackExecuted = false;

        final transactionBoundary = InMemoryFinancialTransactionBoundary(
          onRollback: (context, error, stackTrace) async {
            rollbackExecuted = true;
            expect(error, same(engineError));
          },
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
        );

        final runtime = TransactionalFinancialRuntime(
          pipelineEngine: _ThrowingFinancialPipelineEngine(error: engineError),
          transactionBoundary: transactionBoundary,
          clock: () => DateTime.utc(2026, 7, 17, 20),
        );

        final result = await runtime.execute(
          pipeline: _TestFinancialPipeline(),
          executionContext: _createExecutionContext(),
        );

        expect(rollbackExecuted, isTrue);

        expect(result, isA<FinancialRuntimeInfrastructureFailure>());

        final infrastructureFailure =
            result as FinancialRuntimeInfrastructureFailure;

        expect(infrastructureFailure.error, same(engineError));

        expect(infrastructureFailure.pipelineResultOrNull, isNull);

        expect(infrastructureFailure.hasPipelineResult, isFalse);
      },
    );

    test(
      'should capture an exception unexpectedly thrown by boundary',
      () async {
        final boundaryError = StateError('Transaction provider unavailable.');

        final runtime = TransactionalFinancialRuntime(
          pipelineEngine: _RecordingFinancialPipelineEngine(
            result: const FinancialPipelineSuccess(
              pipelineId: 'pipeline-001',
              executedSteps: 1,
              duration: Duration.zero,
            ),
          ),
          transactionBoundary: _ThrowingFinancialTransactionBoundary(
            error: boundaryError,
          ),
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 1),
        );

        final result = await runtime.execute(
          pipeline: _TestFinancialPipeline(),
          executionContext: _createExecutionContext(),
        );

        expect(result, isA<FinancialRuntimeInfrastructureFailure>());

        final infrastructureFailure =
            result as FinancialRuntimeInfrastructureFailure;

        expect(infrastructureFailure.error, same(boundaryError));

        expect(infrastructureFailure.pipelineResultOrNull, isNull);

        expect(
          infrastructureFailure.transactionId,
          'execution-001:transaction:1',
        );
      },
    );

    test('should use custom transaction identifier factory', () async {
      FinancialTransactionContext? receivedTransactionContext;

      final boundary = _RecordingCommittedTransactionBoundary(
        onContext: (context) {
          receivedTransactionContext = context;
        },
      );

      final runtime = TransactionalFinancialRuntime(
        pipelineEngine: _RecordingFinancialPipelineEngine(
          result: const FinancialPipelineSuccess(
            pipelineId: 'pipeline-001',
            executedSteps: 1,
            duration: Duration.zero,
          ),
        ),
        transactionBoundary: boundary,
        transactionIdFactory:
            ({required executionId, required correlationId, required attempt}) {
              return 'tx-$correlationId-$attempt';
            },
        clock: () => DateTime.utc(2026, 7, 17, 20),
      );

      final result = await runtime.execute(
        pipeline: _TestFinancialPipeline(),
        executionContext: _createExecutionContext(
          executionId: 'execution-789',
          correlationId: 'consultation-456',
          attempt: 3,
        ),
      );

      expect(result.isSuccess, isTrue);

      expect(receivedTransactionContext, isNotNull);

      expect(
        receivedTransactionContext!.transactionId,
        'tx-consultation-456-3',
      );

      expect(receivedTransactionContext!.executionId, 'execution-789');

      expect(receivedTransactionContext!.correlationId, 'consultation-456');
    });

    test('should reject empty generated transaction identifier', () async {
      final runtime = TransactionalFinancialRuntime(
        pipelineEngine: _RecordingFinancialPipelineEngine(
          result: const FinancialPipelineSuccess(
            pipelineId: 'pipeline-001',
            executedSteps: 1,
            duration: Duration.zero,
          ),
        ),
        transactionBoundary: InMemoryFinancialTransactionBoundary(),
        transactionIdFactory:
            ({required executionId, required correlationId, required attempt}) {
              return '   ';
            },
      );

      final future = runtime.execute(
        pipeline: _TestFinancialPipeline(),
        executionContext: _createExecutionContext(),
      );

      await expectLater(future, throwsA(isA<ArgumentError>()));
    });

    test('should preserve execution identities attempt and metadata', () async {
      final sourceMetadata = <String, Object?>{
        'provider': 'paydunya',
        'country': 'ML',
      };

      FinancialTransactionContext? receivedTransactionContext;

      final runtime = TransactionalFinancialRuntime(
        pipelineEngine: _RecordingFinancialPipelineEngine(
          result: const FinancialPipelineSuccess(
            pipelineId: 'consultation-settlement',
            executedSteps: 2,
            duration: Duration(milliseconds: 250),
          ),
        ),
        transactionBoundary: _RecordingCommittedTransactionBoundary(
          onContext: (context) {
            receivedTransactionContext = context;
          },
        ),
        clock: () => DateTime.utc(2026, 7, 17, 20),
      );

      final result = await runtime.execute(
        pipeline: _TestFinancialPipeline(id: 'consultation-settlement'),
        executionContext:
            FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
              executionId: 'execution-002',
              correlationId: 'consultation-777',
              pipelineContext: _TestFinancialPipelineContext(),
              startedAt: DateTime.utc(2026, 7, 17, 20),
              attempt: 2,
              metadata: sourceMetadata,
            ),
      );

      sourceMetadata['provider'] = 'modified';

      expect(result.executionId, 'execution-002');

      expect(result.correlationId, 'consultation-777');

      expect(result.attempt, 2);
      expect(result.isRetry, isTrue);

      expect(result.metadata['provider'], 'paydunya');

      expect(result.metadata['country'], 'ML');

      expect(receivedTransactionContext!.metadata['provider'], 'paydunya');

      expect(
        () => result.metadata['new-key'] = 'value',
        throwsUnsupportedError,
      );
    });

    test(
      'should treat committed pipeline failure as contract violation',
      () async {
        final pipelineError = StateError('Pipeline failed.');

        final pipelineFailure = FinancialPipelineFailure(
          pipelineId: 'pipeline-001',
          executedSteps: 0,
          duration: Duration.zero,
          failedStepId: 'step-001',
          error: pipelineError,
          stackTrace: StackTrace.current,
        );

        final runtime = TransactionalFinancialRuntime(
          pipelineEngine: _RecordingFinancialPipelineEngine(
            result: pipelineFailure,
          ),
          transactionBoundary: _BoundaryThatCommitsReturnedValue(
            value: pipelineFailure,
          ),
          clock: () => DateTime.utc(2026, 7, 17, 20),
        );

        final result = await runtime.execute(
          pipeline: _TestFinancialPipeline(),
          executionContext: _createExecutionContext(),
        );

        expect(result, isA<FinancialRuntimeInfrastructureFailure>());

        final infrastructureFailure =
            result as FinancialRuntimeInfrastructureFailure;

        expect(infrastructureFailure.error, isA<StateError>());

        expect(
          infrastructureFailure.error.toString(),
          contains('committed even though'),
        );

        expect(infrastructureFailure.originalError, same(pipelineError));

        expect(
          infrastructureFailure.pipelineResultOrNull,
          same(pipelineFailure),
        );

        expect(infrastructureFailure.isInfrastructureFailure, isTrue);
      },
    );
  });
}

FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>
_createExecutionContext({
  String executionId = 'execution-001',
  String correlationId = 'consultation-001',
  int attempt = 1,
  Map<String, Object?> metadata = const {
    'source': 'transactional-financial-runtime-test',
  },
}) {
  return FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
    executionId: executionId,
    correlationId: correlationId,
    pipelineContext: _TestFinancialPipelineContext(),
    startedAt: DateTime.utc(2026, 7, 17, 20),
    attempt: attempt,
    metadata: metadata,
  );
}

final class _TestFinancialPipelineContext extends FinancialPipelineContext {
  _TestFinancialPipelineContext();
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
  _RecordingFinancialPipelineEngine({
    required FinancialPipelineResult result,
    void Function()? onExecute,
  }) : _result = result,
       _onExecute = onExecute;

  final FinancialPipelineResult _result;
  final void Function()? _onExecute;

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

    _onExecute?.call();

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

final class _ThrowingFinancialTransactionBoundary
    implements FinancialTransactionBoundary {
  _ThrowingFinancialTransactionBoundary({required this.error});

  final Object error;

  @override
  Future<FinancialTransactionResult<T>> execute<T>({
    required FinancialTransactionContext context,
    required Future<T> Function() action,
  }) async {
    throw error;
  }
}

final class _RecordingCommittedTransactionBoundary
    implements FinancialTransactionBoundary {
  _RecordingCommittedTransactionBoundary({this.onContext});

  final void Function(FinancialTransactionContext context)? onContext;

  @override
  Future<FinancialTransactionResult<T>> execute<T>({
    required FinancialTransactionContext context,
    required Future<T> Function() action,
  }) async {
    onContext?.call(context);

    final value = await action();

    return FinancialTransactionCommitted<T>(
      transactionId: context.transactionId,
      executionId: context.executionId,
      correlationId: context.correlationId,
      value: value,
      startedAt: context.startedAt,
      completedAt: context.startedAt,
      metadata: context.metadata,
    );
  }
}

/// Deliberately broken boundary used to verify that the Runtime detects
/// a transaction provider that commits despite a pipeline failure.
final class _BoundaryThatCommitsReturnedValue
    implements FinancialTransactionBoundary {
  _BoundaryThatCommitsReturnedValue({required this.value});

  final Object value;

  @override
  Future<FinancialTransactionResult<T>> execute<T>({
    required FinancialTransactionContext context,
    required Future<T> Function() action,
  }) async {
    try {
      await action();
    } catch (_) {
      /*
       * Deliberately ignores the private rollback signal emitted by the
       * TransactionalFinancialRuntime.
       *
       * A real boundary must never behave this way.
       */
    }

    return FinancialTransactionCommitted<T>(
      transactionId: context.transactionId,
      executionId: context.executionId,
      correlationId: context.correlationId,
      value: value as T,
      startedAt: context.startedAt,
      completedAt: context.startedAt,
      metadata: context.metadata,
    );
  }
}
