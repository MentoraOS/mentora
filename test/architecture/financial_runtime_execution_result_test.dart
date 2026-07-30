import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_result.dart';
import 'package:mentora/core/financial/runtime/result/'
    'financial_runtime_execution_result.dart';

void main() {
  group('FinancialRuntimeExecutionResult', () {
    test('should create a successful Runtime result from pipeline success', () {
      const pipelineResult = FinancialPipelineSuccess(
        pipelineId: 'consultation-settlement',
        executedSteps: 3,
        duration: Duration(milliseconds: 250),
      );

      final result = FinancialRuntimeExecutionResult.fromPipelineResult(
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        pipelineResult: pipelineResult,
        startedAt: DateTime.utc(2026, 7, 17, 20),
        completedAt: DateTime.utc(2026, 7, 17, 20, 0, 1),
        attempt: 1,
      );

      expect(result, isA<FinancialRuntimeExecutionSuccess>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.executionId, 'execution-001');
      expect(result.correlationId, 'consultation-001');
      expect(result.pipelineId, 'consultation-settlement');
      expect(result.executedSteps, 3);
      expect(result.pipelineDuration, const Duration(milliseconds: 250));
      expect(result.runtimeDuration, const Duration(seconds: 1));
      expect(result.attempt, 1);
      expect(result.isRetry, isFalse);
      expect(result.pipelineResult, same(pipelineResult));
    });

    test('should create a failed Runtime result from pipeline failure', () {
      final error = StateError('Posting failed');
      final stackTrace = StackTrace.current;

      final pipelineResult = FinancialPipelineFailure(
        pipelineId: 'consultation-settlement',
        executedSteps: 2,
        duration: const Duration(milliseconds: 180),
        failedStepId: 'post-ledger-journal',
        error: error,
        stackTrace: stackTrace,
      );

      final result = FinancialRuntimeExecutionResult.fromPipelineResult(
        executionId: 'execution-002',
        correlationId: 'consultation-001',
        pipelineResult: pipelineResult,
        startedAt: DateTime.utc(2026, 7, 17, 20),
        completedAt: DateTime.utc(2026, 7, 17, 20, 0, 1),
        attempt: 2,
      );

      expect(result, isA<FinancialRuntimeExecutionFailure>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.executedSteps, 2);
      expect(result.attempt, 2);
      expect(result.isRetry, isTrue);

      final failure = result as FinancialRuntimeExecutionFailure;

      expect(failure.failedStepId, 'post-ledger-journal');
      expect(failure.error, same(error));
      expect(failure.stackTrace, same(stackTrace));
      expect(failure.pipelineResult, same(pipelineResult));
    });

    test('should trim execution and correlation identifiers', () {
      final result = FinancialRuntimeExecutionResult.fromPipelineResult(
        executionId: '  execution-001  ',
        correlationId: '  consultation-001  ',
        pipelineResult: const FinancialPipelineSuccess(
          pipelineId: 'pipeline-001',
          executedSteps: 1,
          duration: Duration.zero,
        ),
        startedAt: DateTime.utc(2026, 7, 17),
        completedAt: DateTime.utc(2026, 7, 17),
        attempt: 1,
      );

      expect(result.executionId, 'execution-001');
      expect(result.correlationId, 'consultation-001');
    });

    test('should normalize timestamps to UTC', () {
      final startedAt = DateTime(2026, 7, 17, 20);

      final completedAt = startedAt.add(const Duration(seconds: 2));

      final result = FinancialRuntimeExecutionResult.fromPipelineResult(
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        pipelineResult: const FinancialPipelineSuccess(
          pipelineId: 'pipeline-001',
          executedSteps: 1,
          duration: Duration(seconds: 1),
        ),
        startedAt: startedAt,
        completedAt: completedAt,
        attempt: 1,
      );

      expect(result.startedAt.isUtc, isTrue);
      expect(result.completedAt.isUtc, isTrue);
      expect(result.startedAt, startedAt.toUtc());
      expect(result.completedAt, completedAt.toUtc());
    });

    test('should expose immutable metadata', () {
      final originalMetadata = <String, Object?>{'provider': 'paydunya'};

      final result = FinancialRuntimeExecutionResult.fromPipelineResult(
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        pipelineResult: const FinancialPipelineSuccess(
          pipelineId: 'pipeline-001',
          executedSteps: 1,
          duration: Duration.zero,
        ),
        startedAt: DateTime.utc(2026, 7, 17),
        completedAt: DateTime.utc(2026, 7, 17),
        attempt: 1,
        metadata: originalMetadata,
      );

      originalMetadata['provider'] = 'modified';

      expect(result.metadata['provider'], 'paydunya');

      expect(
        () => result.metadata['new-key'] = 'value',
        throwsUnsupportedError,
      );
    });

    test('should reject an empty execution identifier', () {
      expect(
        () => FinancialRuntimeExecutionResult.fromPipelineResult(
          executionId: '   ',
          correlationId: 'consultation-001',
          pipelineResult: const FinancialPipelineSuccess(
            pipelineId: 'pipeline-001',
            executedSteps: 1,
            duration: Duration.zero,
          ),
          startedAt: DateTime.utc(2026, 7, 17),
          completedAt: DateTime.utc(2026, 7, 17),
          attempt: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should reject an empty correlation identifier', () {
      expect(
        () => FinancialRuntimeExecutionResult.fromPipelineResult(
          executionId: 'execution-001',
          correlationId: '',
          pipelineResult: const FinancialPipelineSuccess(
            pipelineId: 'pipeline-001',
            executedSteps: 1,
            duration: Duration.zero,
          ),
          startedAt: DateTime.utc(2026, 7, 17),
          completedAt: DateTime.utc(2026, 7, 17),
          attempt: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should reject an execution attempt lower than one', () {
      expect(
        () => FinancialRuntimeExecutionResult.fromPipelineResult(
          executionId: 'execution-001',
          correlationId: 'consultation-001',
          pipelineResult: const FinancialPipelineSuccess(
            pipelineId: 'pipeline-001',
            executedSteps: 1,
            duration: Duration.zero,
          ),
          startedAt: DateTime.utc(2026, 7, 17),
          completedAt: DateTime.utc(2026, 7, 17),
          attempt: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should reject completion before execution start', () {
      expect(
        () => FinancialRuntimeExecutionResult.fromPipelineResult(
          executionId: 'execution-001',
          correlationId: 'consultation-001',
          pipelineResult: const FinancialPipelineSuccess(
            pipelineId: 'pipeline-001',
            executedSteps: 1,
            duration: Duration.zero,
          ),
          startedAt: DateTime.utc(2026, 7, 17, 20),
          completedAt: DateTime.utc(2026, 7, 17, 19),
          attempt: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('runtime duration may include more work than pipeline duration', () {
      final result = FinancialRuntimeExecutionResult.fromPipelineResult(
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        pipelineResult: const FinancialPipelineSuccess(
          pipelineId: 'pipeline-001',
          executedSteps: 2,
          duration: Duration(milliseconds: 600),
        ),
        startedAt: DateTime.utc(2026, 7, 17, 20),
        completedAt: DateTime.utc(2026, 7, 17, 20, 0, 1),
        attempt: 1,
      );

      expect(result.pipelineDuration, const Duration(milliseconds: 600));

      expect(result.runtimeDuration, const Duration(seconds: 1));
    });

    test('should create an infrastructure failure without pipeline result', () {
      final infrastructureError = StateError('Unable to begin transaction.');

      final stackTrace = StackTrace.current;

      final result = FinancialRuntimeInfrastructureFailure(
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        transactionId: 'transaction-001',
        error: infrastructureError,
        stackTrace: stackTrace,
        startedAt: DateTime.utc(2026, 7, 17, 20),
        completedAt: DateTime.utc(2026, 7, 17, 20, 0, 1),
        attempt: 1,
      );

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isFalse);
      expect(result.isInfrastructureFailure, isTrue);

      expect(result.transactionId, 'transaction-001');

      expect(result.error, same(infrastructureError));
      expect(result.stackTrace, same(stackTrace));

      expect(result.hasPipelineResult, isFalse);
      expect(result.pipelineResultOrNull, isNull);

      expect(result.occurredAfterPipelineExecution, isFalse);

      expect(() => result.pipelineResult, throwsStateError);

      expect(() => result.pipelineId, throwsStateError);
    });

    test('should preserve pipeline result when commit fails', () {
      const pipelineResult = FinancialPipelineSuccess(
        pipelineId: 'consultation-settlement',
        executedSteps: 3,
        duration: Duration(milliseconds: 500),
      );

      final commitError = StateError('Transaction commit failed.');

      final result = FinancialRuntimeInfrastructureFailure(
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        transactionId: 'transaction-001',
        error: commitError,
        stackTrace: StackTrace.current,
        pipelineResult: pipelineResult,
        startedAt: DateTime.utc(2026, 7, 17, 20),
        completedAt: DateTime.utc(2026, 7, 17, 20, 0, 1),
        attempt: 1,
      );

      expect(result.hasPipelineResult, isTrue);

      expect(result.pipelineResultOrNull, same(pipelineResult));

      expect(result.pipelineResult, same(pipelineResult));

      expect(result.pipelineId, 'consultation-settlement');

      expect(result.executedSteps, 3);

      expect(result.occurredAfterPipelineExecution, isTrue);
    });

    test('should preserve original pipeline error when rollback fails', () {
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

      final rollbackError = StateError('Transaction rollback failed.');

      final rollbackStackTrace = StackTrace.current;

      final result = FinancialRuntimeInfrastructureFailure(
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        transactionId: 'transaction-001',
        error: rollbackError,
        stackTrace: rollbackStackTrace,
        originalError: pipelineError,
        originalStackTrace: pipelineStackTrace,
        pipelineResult: pipelineFailure,
        startedAt: DateTime.utc(2026, 7, 17, 20),
        completedAt: DateTime.utc(2026, 7, 17, 20, 0, 1),
        attempt: 1,
      );

      expect(result.error, same(rollbackError));

      expect(result.stackTrace, same(rollbackStackTrace));

      expect(result.originalError, same(pipelineError));

      expect(result.originalStackTrace, same(pipelineStackTrace));

      expect(result.pipelineResultOrNull, same(pipelineFailure));

      expect(result.pipelineId, 'consultation-settlement');
    });

    test('infrastructure failure should trim transaction identifier', () {
      final result = FinancialRuntimeInfrastructureFailure(
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        transactionId: '  transaction-001  ',
        error: StateError('Commit failed.'),
        stackTrace: StackTrace.current,
        startedAt: DateTime.utc(2026, 7, 17),
        completedAt: DateTime.utc(2026, 7, 17),
        attempt: 1,
      );

      expect(result.transactionId, 'transaction-001');
    });

    test(
      'infrastructure failure should reject empty transaction identifier',
      () {
        expect(
          () => FinancialRuntimeInfrastructureFailure(
            executionId: 'execution-001',
            correlationId: 'consultation-001',
            transactionId: '   ',
            error: StateError('Commit failed.'),
            stackTrace: StackTrace.current,
            startedAt: DateTime.utc(2026, 7, 17),
            completedAt: DateTime.utc(2026, 7, 17),
            attempt: 1,
          ),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('regular Runtime results should expose available pipeline result', () {
      const pipelineResult = FinancialPipelineSuccess(
        pipelineId: 'pipeline-001',
        executedSteps: 1,
        duration: Duration.zero,
      );

      final result = FinancialRuntimeExecutionResult.fromPipelineResult(
        executionId: 'execution-001',
        correlationId: 'consultation-001',
        pipelineResult: pipelineResult,
        startedAt: DateTime.utc(2026, 7, 17),
        completedAt: DateTime.utc(2026, 7, 17),
        attempt: 1,
      );

      expect(result.hasPipelineResult, isTrue);

      expect(result.pipelineResultOrNull, same(pipelineResult));

      expect(result.isInfrastructureFailure, isFalse);
    });
  });
}
