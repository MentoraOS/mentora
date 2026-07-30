import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/financial_pipeline_context.dart';
import 'package:mentora/core/financial/runtime/context/'
    'financial_runtime_execution_context.dart';

void main() {
  group('FinancialRuntimeExecutionContext', () {
    test('should preserve execution identity and pipeline context', () {
      final pipelineContext = _TestFinancialPipelineContext();

      final context =
          FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
            executionId: 'execution-001',
            correlationId: 'consultation-001',
            pipelineContext: pipelineContext,
            startedAt: DateTime.utc(2026, 7, 17, 20),
          );

      expect(context.executionId, 'execution-001');
      expect(context.correlationId, 'consultation-001');
      expect(context.pipelineContext, same(pipelineContext));
      expect(context.startedAt, DateTime.utc(2026, 7, 17, 20));
      expect(context.attempt, 1);
      expect(context.metadata, isEmpty);
      expect(context.isRetry, isFalse);
    });

    test('should trim execution and correlation identifiers', () {
      final context =
          FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
            executionId: '  execution-001  ',
            correlationId: '  consultation-001  ',
            pipelineContext: _TestFinancialPipelineContext(),
            startedAt: DateTime.utc(2026, 7, 17),
          );

      expect(context.executionId, 'execution-001');
      expect(context.correlationId, 'consultation-001');
    });

    test('should normalize startedAt to UTC', () {
      final localStartedAt = DateTime(2026, 7, 17, 20, 30);

      final context =
          FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
            executionId: 'execution-001',
            correlationId: 'consultation-001',
            pipelineContext: _TestFinancialPipelineContext(),
            startedAt: localStartedAt,
          );

      expect(context.startedAt.isUtc, isTrue);
      expect(context.startedAt, localStartedAt.toUtc());
    });

    test('should expose immutable metadata', () {
      final originalMetadata = <String, Object?>{
        'source': 'settlement-workflow',
      };

      final context =
          FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
            executionId: 'execution-001',
            correlationId: 'consultation-001',
            pipelineContext: _TestFinancialPipelineContext(),
            startedAt: DateTime.utc(2026, 7, 17),
            metadata: originalMetadata,
          );

      originalMetadata['source'] = 'modified';

      expect(context.metadata['source'], 'settlement-workflow');

      expect(
        () => context.metadata['new-key'] = 'new-value',
        throwsUnsupportedError,
      );
    });

    test('should reject an empty execution identifier', () {
      expect(
        () => FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
          executionId: '   ',
          correlationId: 'consultation-001',
          pipelineContext: _TestFinancialPipelineContext(),
          startedAt: DateTime.utc(2026, 7, 17),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should reject an empty correlation identifier', () {
      expect(
        () => FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
          executionId: 'execution-001',
          correlationId: '',
          pipelineContext: _TestFinancialPipelineContext(),
          startedAt: DateTime.utc(2026, 7, 17),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should reject an execution attempt lower than one', () {
      expect(
        () => FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
          executionId: 'execution-001',
          correlationId: 'consultation-001',
          pipelineContext: _TestFinancialPipelineContext(),
          startedAt: DateTime.utc(2026, 7, 17),
          attempt: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('nextAttempt should preserve correlation and increment attempt', () {
      final pipelineContext = _TestFinancialPipelineContext();

      final firstAttempt =
          FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
            executionId: 'execution-001',
            correlationId: 'consultation-001',
            pipelineContext: pipelineContext,
            startedAt: DateTime.utc(2026, 7, 17, 20),
            metadata: const {'provider': 'paydunya'},
          );

      final secondAttempt = firstAttempt.nextAttempt(
        executionId: 'execution-002',
        startedAt: DateTime.utc(2026, 7, 17, 20, 5),
      );

      expect(secondAttempt.executionId, 'execution-002');
      expect(secondAttempt.correlationId, firstAttempt.correlationId);
      expect(secondAttempt.pipelineContext, same(pipelineContext));
      expect(secondAttempt.attempt, 2);
      expect(secondAttempt.isRetry, isTrue);
      expect(secondAttempt.metadata, firstAttempt.metadata);
    });

    test('copyWith should replace only explicitly provided values', () {
      final pipelineContext = _TestFinancialPipelineContext();

      final original =
          FinancialRuntimeExecutionContext<_TestFinancialPipelineContext>(
            executionId: 'execution-001',
            correlationId: 'consultation-001',
            pipelineContext: pipelineContext,
            startedAt: DateTime.utc(2026, 7, 17),
          );

      final copy = original.copyWith(executionId: 'execution-002', attempt: 2);

      expect(copy.executionId, 'execution-002');
      expect(copy.correlationId, original.correlationId);
      expect(copy.pipelineContext, same(pipelineContext));
      expect(copy.startedAt, original.startedAt);
      expect(copy.attempt, 2);
      expect(copy.isRetry, isTrue);
    });
  });
}

final class _TestFinancialPipelineContext extends FinancialPipelineContext {
  const _TestFinancialPipelineContext();
}
