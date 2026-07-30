import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';

import 'package:mentora/core/financial/pipeline/recovery/engine/'
    'financial_recovery_engine.dart';

import 'package:mentora/core/financial/pipeline/recovery/events/'
    'financial_recovery_pipeline_event.dart';
import 'package:mentora/core/financial/pipeline/recovery/events/'
    'financial_recovery_pipeline_event_dispatcher.dart';

import 'package:mentora/core/financial/pipeline/recovery/pipeline/'
    'default_financial_recovery_pipeline.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_decision.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_request.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_result.dart';

void main() {
  group('DefaultFinancialRecoveryPipeline', () {
    late DateTime fixedNow;

    late FinancialRecoveryStrategyRequest<_TestRecoveryContext> request;

    setUp(() {
      fixedNow = DateTime.utc(2026, 7, 17, 12);

      request = FinancialRecoveryStrategyRequest<_TestRecoveryContext>(
        recoveryId: 'recovery_001',
        pipelineId: 'test.recovery.pipeline',
        context: const _TestRecoveryContext(operationId: 'operation_001'),
        error: StateError('Original financial operation failed.'),
        stackTrace: StackTrace.current,
        attempt: 2,
        requestedAt: DateTime.utc(2026, 7, 17, 11),
        metadata: const {
          'trigger': 'architecture_test',
          'tenantId': 'tenant_001',
        },
      );
    });

    test('emits STARTED, SUCCEEDED and FINISHED in order', () async {
      final expectedResult = FinancialRecoveryStrategySuccess(
        recoveryId: request.recoveryId,
        strategyKey: 'test.recovery.strategy',
        decision: FinancialRecoveryDecision.ignore,
        attempt: request.attempt,
        duration: const Duration(milliseconds: 12),
        completedAt: fixedNow,
        metadata: const {'result': 'success'},
      );

      final engine = _FakeFinancialRecoveryEngine(result: expectedResult);

      final events = <FinancialRecoveryPipelineEvent>[];

      final dispatcher = FinancialRecoveryPipelineEventDispatcher(
        listeners: [events.add],
      );

      final pipeline = DefaultFinancialRecoveryPipeline(
        recoveryEngine: engine,
        eventDispatcher: dispatcher,
        clock: () => fixedNow,
      );

      final result = await pipeline.execute(request: request);

      expect(result, same(expectedResult));

      expect(engine.callCount, 1);

      expect(engine.receivedRequest, same(request));

      expect(events, hasLength(3));

      expect(
        events[0],
        isA<FinancialRecoveryPipelineStarted<_TestRecoveryContext>>(),
      );

      expect(
        events[1],
        isA<FinancialRecoveryPipelineSucceeded<_TestRecoveryContext>>(),
      );

      expect(
        events[2],
        isA<FinancialRecoveryPipelineFinished<_TestRecoveryContext>>(),
      );
    });

    test(
      'preserves the request and success result in emitted events',
      () async {
        final expectedResult = FinancialRecoveryStrategySuccess(
          recoveryId: request.recoveryId,
          strategyKey: 'test.recovery.strategy',
          decision: FinancialRecoveryDecision.ignore,
          attempt: request.attempt,
          duration: const Duration(milliseconds: 10),
          completedAt: fixedNow,
          metadata: const {'result': 'success'},
        );

        final engine = _FakeFinancialRecoveryEngine(result: expectedResult);

        final events = <FinancialRecoveryPipelineEvent>[];

        final pipeline = DefaultFinancialRecoveryPipeline(
          recoveryEngine: engine,
          eventDispatcher: FinancialRecoveryPipelineEventDispatcher(
            listeners: [events.add],
          ),
          clock: () => fixedNow,
        );

        await pipeline.execute(request: request);

        final started =
            events[0] as FinancialRecoveryPipelineStarted<_TestRecoveryContext>;

        final succeeded =
            events[1]
                as FinancialRecoveryPipelineSucceeded<_TestRecoveryContext>;

        final finished =
            events[2]
                as FinancialRecoveryPipelineFinished<_TestRecoveryContext>;

        expect(started.request, same(request));

        expect(succeeded.request, same(request));

        expect(succeeded.result, same(expectedResult));

        expect(finished.request, same(request));

        expect(started.recoveryId, request.recoveryId);

        expect(succeeded.pipelineId, request.pipelineId);

        expect(finished.attempt, request.attempt);

        expect(started.occurredAt, fixedNow);

        expect(succeeded.occurredAt, fixedNow);

        expect(finished.occurredAt, fixedNow);
      },
    );

    test(
      'emits STARTED, FAILED and FINISHED for a controlled failure',
      () async {
        final recoveryError = StateError('Manual review is required.');

        final recoveryStackTrace = StackTrace.current;

        final expectedResult = FinancialRecoveryStrategyFailure(
          recoveryId: request.recoveryId,
          strategyKey: 'test.recovery.strategy',
          decision: FinancialRecoveryDecision.manualReview,
          attempt: request.attempt,
          duration: const Duration(milliseconds: 18),
          completedAt: fixedNow,
          error: recoveryError,
          stackTrace: recoveryStackTrace,
          metadata: const {'reason': 'ledger_conflict'},
        );

        final engine = _FakeFinancialRecoveryEngine(result: expectedResult);

        final events = <FinancialRecoveryPipelineEvent>[];

        final pipeline = DefaultFinancialRecoveryPipeline(
          recoveryEngine: engine,
          eventDispatcher: FinancialRecoveryPipelineEventDispatcher(
            listeners: [events.add],
          ),
          clock: () => fixedNow,
        );

        final result = await pipeline.execute(request: request);

        expect(result, same(expectedResult));

        expect(engine.callCount, 1);

        expect(events, hasLength(3));

        expect(
          events[0],
          isA<FinancialRecoveryPipelineStarted<_TestRecoveryContext>>(),
        );

        expect(
          events[1],
          isA<FinancialRecoveryPipelineFailed<_TestRecoveryContext>>(),
        );

        expect(
          events[2],
          isA<FinancialRecoveryPipelineFinished<_TestRecoveryContext>>(),
        );

        final failed =
            events[1] as FinancialRecoveryPipelineFailed<_TestRecoveryContext>;

        expect(failed.request, same(request));

        expect(failed.result, same(expectedResult));

        expect(failed.result.decision, FinancialRecoveryDecision.manualReview);

        expect(failed.result.error, same(recoveryError));

        expect(failed.result.stackTrace, same(recoveryStackTrace));
      },
    );

    test(
      'emits STARTED, CRASHED and FINISHED and rethrows the original error',
      () async {
        final expectedError = StateError('Recovery infrastructure crashed.');

        final engine = _FakeFinancialRecoveryEngine(error: expectedError);

        final events = <FinancialRecoveryPipelineEvent>[];

        final pipeline = DefaultFinancialRecoveryPipeline(
          recoveryEngine: engine,
          eventDispatcher: FinancialRecoveryPipelineEventDispatcher(
            listeners: [events.add],
          ),
          clock: () => fixedNow,
        );

        Object? capturedError;
        StackTrace? capturedStackTrace;

        try {
          await pipeline.execute(request: request);

          fail(
            'The pipeline should have rethrown '
            'the recovery engine error.',
          );
        } catch (error, stackTrace) {
          capturedError = error;
          capturedStackTrace = stackTrace;
        }

        expect(capturedError, same(expectedError));

        expect(capturedStackTrace, isNotNull);

        expect(engine.callCount, 1);

        expect(engine.receivedRequest, same(request));

        expect(events, hasLength(3));

        expect(
          events[0],
          isA<FinancialRecoveryPipelineStarted<_TestRecoveryContext>>(),
        );

        expect(
          events[1],
          isA<FinancialRecoveryPipelineCrashed<_TestRecoveryContext>>(),
        );

        expect(
          events[2],
          isA<FinancialRecoveryPipelineFinished<_TestRecoveryContext>>(),
        );

        final crashed =
            events[1] as FinancialRecoveryPipelineCrashed<_TestRecoveryContext>;

        expect(crashed.request, same(request));

        expect(crashed.error, same(expectedError));

        expect(crashed.stackTrace, isNotNull);
      },
    );

    test('dispatches STARTED before invoking the recovery engine', () async {
      final executionOrder = <String>[];

      final expectedResult = FinancialRecoveryStrategySuccess(
        recoveryId: request.recoveryId,
        strategyKey: 'test.recovery.strategy',
        decision: FinancialRecoveryDecision.ignore,
        attempt: request.attempt,
        duration: Duration.zero,
        completedAt: fixedNow,
      );

      final engine = _FakeFinancialRecoveryEngine(
        result: expectedResult,
        beforeRecover: () {
          executionOrder.add('engine');
        },
      );

      final dispatcher = FinancialRecoveryPipelineEventDispatcher(
        listeners: [
          (event) {
            if (event is FinancialRecoveryPipelineStarted) {
              executionOrder.add('started');
            } else if (event is FinancialRecoveryPipelineSucceeded) {
              executionOrder.add('succeeded');
            } else if (event is FinancialRecoveryPipelineFinished) {
              executionOrder.add('finished');
            }
          },
        ],
      );

      final pipeline = DefaultFinancialRecoveryPipeline(
        recoveryEngine: engine,
        eventDispatcher: dispatcher,
        clock: () => fixedNow,
      );

      await pipeline.execute(request: request);

      expect(executionOrder, ['started', 'engine', 'succeeded', 'finished']);
    });

    test('adds deterministic lifecycle metadata to events', () async {
      final expectedResult = FinancialRecoveryStrategySuccess(
        recoveryId: request.recoveryId,
        strategyKey: 'test.recovery.strategy',
        decision: FinancialRecoveryDecision.ignore,
        attempt: request.attempt,
        duration: Duration.zero,
        completedAt: fixedNow,
      );

      final events = <FinancialRecoveryPipelineEvent>[];

      final pipeline = DefaultFinancialRecoveryPipeline(
        recoveryEngine: _FakeFinancialRecoveryEngine(result: expectedResult),
        eventDispatcher: FinancialRecoveryPipelineEventDispatcher(
          listeners: [events.add],
        ),
        clock: () => fixedNow,
      );

      await pipeline.execute(request: request);

      final started = events[0];
      final succeeded = events[1];
      final finished = events[2];

      expect(started.metadata['trigger'], 'architecture_test');

      expect(started.metadata['recoveryPipelinePhase'], 'started');

      expect(succeeded.metadata['recoveryPipelinePhase'], 'succeeded');

      expect(succeeded.metadata['strategyKey'], 'test.recovery.strategy');

      expect(
        succeeded.metadata['decision'],
        FinancialRecoveryDecision.ignore.name,
      );

      expect(finished.metadata['recoveryPipelinePhase'], 'finished');

      expect(finished.metadata['tenantId'], 'tenant_001');
    });

    test(
      'uses the same measured duration for outcome and finished events',
      () async {
        final expectedResult = FinancialRecoveryStrategySuccess(
          recoveryId: request.recoveryId,
          strategyKey: 'test.recovery.strategy',
          decision: FinancialRecoveryDecision.ignore,
          attempt: request.attempt,
          duration: Duration.zero,
          completedAt: fixedNow,
        );

        final events = <FinancialRecoveryPipelineEvent>[];

        final pipeline = DefaultFinancialRecoveryPipeline(
          recoveryEngine: _FakeFinancialRecoveryEngine(result: expectedResult),
          eventDispatcher: FinancialRecoveryPipelineEventDispatcher(
            listeners: [events.add],
          ),
          clock: () => fixedNow,
        );

        await pipeline.execute(request: request);

        final succeeded =
            events[1]
                as FinancialRecoveryPipelineSucceeded<_TestRecoveryContext>;

        final finished =
            events[2]
                as FinancialRecoveryPipelineFinished<_TestRecoveryContext>;

        expect(succeeded.duration, finished.duration);

        expect(succeeded.duration, isA<Duration>());

        expect(succeeded.duration.isNegative, isFalse);
      },
    );
  });
}

final class _TestRecoveryContext extends FinancialPipelineContext {
  const _TestRecoveryContext({required this.operationId});

  final String operationId;
}

typedef _BeforeRecover = void Function();

final class _FakeFinancialRecoveryEngine implements FinancialRecoveryEngine {
  _FakeFinancialRecoveryEngine({this.result, this.error, this.beforeRecover})
    : assert(
        result != null || error != null,
        'The fake recovery engine requires '
        'either a result or an error.',
      );

  final FinancialRecoveryStrategyResult? result;

  final Object? error;

  final _BeforeRecover? beforeRecover;

  Object? receivedRequest;

  int callCount = 0;

  FinancialRecoveryStrategyRequest<_TestRecoveryContext>
  get typedReceivedRequest {
    return receivedRequest!
        as FinancialRecoveryStrategyRequest<_TestRecoveryContext>;
  }

  @override
  Future<FinancialRecoveryStrategyResult> recover<
    TContext extends FinancialPipelineContext
  >({required FinancialRecoveryStrategyRequest<TContext> request}) async {
    callCount++;

    receivedRequest = request;

    beforeRecover?.call();

    if (error != null) {
      throw error!;
    }

    return result!;
  }
}
