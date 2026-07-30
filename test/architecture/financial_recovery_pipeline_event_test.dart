import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';

import 'package:mentora/core/financial/pipeline/recovery/events/'
    'financial_recovery_pipeline_event.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_decision.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_request.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_result.dart';

void main() {
  group('FinancialRecoveryPipelineEvent', () {
    late FinancialRecoveryStrategyRequest<_TestRecoveryContext> request;

    late DateTime occurredAt;

    setUp(() {
      occurredAt = DateTime.utc(2026, 7, 17, 10);

      request = FinancialRecoveryStrategyRequest<_TestRecoveryContext>(
        recoveryId: 'recovery_001',
        pipelineId: 'test.recovery.pipeline',
        context: const _TestRecoveryContext(operationId: 'operation_001'),
        error: StateError('Original financial operation failed.'),
        stackTrace: StackTrace.current,
        attempt: 2,
        requestedAt: DateTime.utc(2026, 7, 17, 9),
        metadata: const {'trigger': 'architecture_test'},
      );
    });

    test('creates a started event', () {
      final event = FinancialRecoveryPipelineStarted<_TestRecoveryContext>(
        request: request,
        recoveryId: request.recoveryId,
        pipelineId: request.pipelineId,
        attempt: request.attempt,
        occurredAt: occurredAt,
        metadata: const {'phase': 'started'},
      );

      expect(event.request, same(request));

      expect(event.recoveryId, 'recovery_001');

      expect(event.pipelineId, 'test.recovery.pipeline');

      expect(event.attempt, 2);

      expect(event.occurredAt, occurredAt);

      expect(event.metadata['phase'], 'started');
    });

    test('creates a succeeded event', () {
      final result = FinancialRecoveryStrategySuccess(
        recoveryId: request.recoveryId,
        strategyKey: 'test.recovery.strategy',
        decision: FinancialRecoveryDecision.ignore,
        attempt: request.attempt,
        duration: const Duration(milliseconds: 15),
        completedAt: occurredAt,
        metadata: const {'result': 'success'},
      );

      final event = FinancialRecoveryPipelineSucceeded<_TestRecoveryContext>(
        request: request,
        result: result,
        duration: const Duration(milliseconds: 20),
        recoveryId: request.recoveryId,
        pipelineId: request.pipelineId,
        attempt: request.attempt,
        occurredAt: occurredAt,
        metadata: const {'phase': 'succeeded'},
      );

      expect(event.request, same(request));

      expect(event.result, same(result));

      expect(event.duration, const Duration(milliseconds: 20));

      expect(event.result.decision, FinancialRecoveryDecision.ignore);

      expect(event.metadata['phase'], 'succeeded');
    });

    test('creates a controlled failed event', () {
      final error = StateError('Manual review required.');

      final stackTrace = StackTrace.current;

      final result = FinancialRecoveryStrategyFailure(
        recoveryId: request.recoveryId,
        strategyKey: 'test.recovery.strategy',
        decision: FinancialRecoveryDecision.manualReview,
        attempt: request.attempt,
        duration: const Duration(milliseconds: 25),
        completedAt: occurredAt,
        error: error,
        stackTrace: stackTrace,
        metadata: const {'result': 'manual_review'},
      );

      final event = FinancialRecoveryPipelineFailed<_TestRecoveryContext>(
        request: request,
        result: result,
        duration: const Duration(milliseconds: 30),
        recoveryId: request.recoveryId,
        pipelineId: request.pipelineId,
        attempt: request.attempt,
        occurredAt: occurredAt,
        metadata: const {'phase': 'failed'},
      );

      expect(event.request, same(request));

      expect(event.result, same(result));

      expect(event.duration, const Duration(milliseconds: 30));

      expect(event.result.decision, FinancialRecoveryDecision.manualReview);

      expect(event.result.error, same(error));

      expect(event.result.stackTrace, same(stackTrace));

      expect(event.metadata['phase'], 'failed');
    });

    test('creates a crashed event preserving diagnostics', () {
      final error = StateError('Unexpected infrastructure crash.');

      final stackTrace = StackTrace.current;

      final event = FinancialRecoveryPipelineCrashed<_TestRecoveryContext>(
        request: request,
        error: error,
        stackTrace: stackTrace,
        duration: const Duration(milliseconds: 40),
        recoveryId: request.recoveryId,
        pipelineId: request.pipelineId,
        attempt: request.attempt,
        occurredAt: occurredAt,
        metadata: const {'phase': 'crashed'},
      );

      expect(event.request, same(request));

      expect(event.error, same(error));

      expect(event.stackTrace, same(stackTrace));

      expect(event.duration, const Duration(milliseconds: 40));

      expect(event.metadata['phase'], 'crashed');
    });

    test('creates a finished event', () {
      final event = FinancialRecoveryPipelineFinished<_TestRecoveryContext>(
        request: request,
        duration: const Duration(milliseconds: 50),
        recoveryId: request.recoveryId,
        pipelineId: request.pipelineId,
        attempt: request.attempt,
        occurredAt: occurredAt,
        metadata: const {'phase': 'finished'},
      );

      expect(event.request, same(request));

      expect(event.duration, const Duration(milliseconds: 50));

      expect(event.recoveryId, request.recoveryId);

      expect(event.pipelineId, request.pipelineId);

      expect(event.attempt, request.attempt);

      expect(event.metadata['phase'], 'finished');
    });

    test('all lifecycle events share the base event contract', () {
      final started = FinancialRecoveryPipelineStarted<_TestRecoveryContext>(
        request: request,
        recoveryId: request.recoveryId,
        pipelineId: request.pipelineId,
        attempt: request.attempt,
        occurredAt: occurredAt,
      );

      final finished = FinancialRecoveryPipelineFinished<_TestRecoveryContext>(
        request: request,
        duration: Duration.zero,
        recoveryId: request.recoveryId,
        pipelineId: request.pipelineId,
        attempt: request.attempt,
        occurredAt: occurredAt,
      );

      expect(started, isA<FinancialRecoveryPipelineEvent>());

      expect(finished, isA<FinancialRecoveryPipelineEvent>());
    });
  });
}

final class _TestRecoveryContext extends FinancialPipelineContext {
  const _TestRecoveryContext({required this.operationId});

  final String operationId;
}
