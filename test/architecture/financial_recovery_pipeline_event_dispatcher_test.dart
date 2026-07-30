import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';

import 'package:mentora/core/financial/pipeline/recovery/events/'
    'financial_recovery_pipeline_event.dart';
import 'package:mentora/core/financial/pipeline/recovery/events/'
    'financial_recovery_pipeline_event_dispatcher.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_request.dart';

void main() {
  group('FinancialRecoveryPipelineEventDispatcher', () {
    late FinancialRecoveryStrategyRequest<_TestRecoveryContext> request;

    late FinancialRecoveryPipelineStarted<_TestRecoveryContext> event;

    setUp(() {
      request = FinancialRecoveryStrategyRequest<_TestRecoveryContext>(
        recoveryId: 'recovery_001',
        pipelineId: 'test.recovery.pipeline',
        context: const _TestRecoveryContext(operationId: 'operation_001'),
        error: StateError('Original financial operation failed.'),
        stackTrace: StackTrace.current,
        attempt: 1,
        requestedAt: DateTime.utc(2026, 7, 17, 9),
        metadata: const {'trigger': 'architecture_test'},
      );

      event = FinancialRecoveryPipelineStarted<_TestRecoveryContext>(
        request: request,
        recoveryId: request.recoveryId,
        pipelineId: request.pipelineId,
        attempt: request.attempt,
        occurredAt: DateTime.utc(2026, 7, 17, 10),
      );
    });

    test('creates an empty dispatcher', () {
      final dispatcher = FinancialRecoveryPipelineEventDispatcher();

      expect(dispatcher.listenerCount, 0);

      expect(dispatcher.hasListeners, isFalse);

      expect(dispatcher.isEmpty, isTrue);
    });

    test('dispatches the exact event instance to every listener', () async {
      final receivedEvents = <FinancialRecoveryPipelineEvent>[];

      final dispatcher = FinancialRecoveryPipelineEventDispatcher(
        listeners: [receivedEvents.add, receivedEvents.add],
      );

      await dispatcher.dispatch(event);

      expect(dispatcher.listenerCount, 2);

      expect(dispatcher.hasListeners, isTrue);

      expect(dispatcher.isEmpty, isFalse);

      expect(receivedEvents, hasLength(2));

      expect(receivedEvents[0], same(event));

      expect(receivedEvents[1], same(event));
    });

    test('preserves listener registration order', () async {
      final executionOrder = <String>[];

      final dispatcher = FinancialRecoveryPipelineEventDispatcher(
        listeners: [
          (_) {
            executionOrder.add('first');
          },
          (_) {
            executionOrder.add('second');
          },
          (_) {
            executionOrder.add('third');
          },
        ],
      );

      await dispatcher.dispatch(event);

      expect(executionOrder, ['first', 'second', 'third']);
    });

    test('awaits asynchronous listeners before continuing', () async {
      final executionOrder = <String>[];

      final dispatcher = FinancialRecoveryPipelineEventDispatcher(
        listeners: [
          (_) async {
            executionOrder.add('first_started');

            await Future<void>.delayed(const Duration(milliseconds: 20));

            executionOrder.add('first_finished');
          },
          (_) {
            executionOrder.add('second');
          },
        ],
      );

      await dispatcher.dispatch(event);

      expect(executionOrder, ['first_started', 'first_finished', 'second']);
    });

    test('does nothing when no listener is registered', () async {
      final dispatcher = FinancialRecoveryPipelineEventDispatcher();

      await expectLater(dispatcher.dispatch(event), completes);
    });

    test('propagates a listener error unchanged', () async {
      final expectedError = StateError('Listener failed.');

      final executionOrder = <String>[];

      final dispatcher = FinancialRecoveryPipelineEventDispatcher(
        listeners: [
          (_) {
            executionOrder.add('first');
          },
          (_) {
            executionOrder.add('second');

            throw expectedError;
          },
          (_) {
            executionOrder.add('third');
          },
        ],
      );

      Object? capturedError;
      StackTrace? capturedStackTrace;

      try {
        await dispatcher.dispatch(event);

        fail(
          'The dispatcher should have '
          'propagated the listener error.',
        );
      } catch (error, stackTrace) {
        capturedError = error;
        capturedStackTrace = stackTrace;
      }

      expect(capturedError, same(expectedError));

      expect(capturedStackTrace, isNotNull);

      expect(executionOrder, ['first', 'second']);
    });

    test('copies the listener collection at construction time', () async {
      final mutableListeners = <FinancialRecoveryPipelineEventListener>[];

      final receivedEvents = <FinancialRecoveryPipelineEvent>[];

      mutableListeners.add(receivedEvents.add);

      final dispatcher = FinancialRecoveryPipelineEventDispatcher(
        listeners: mutableListeners,
      );

      mutableListeners.add(receivedEvents.add);

      await dispatcher.dispatch(event);

      expect(dispatcher.listenerCount, 1);

      expect(receivedEvents, hasLength(1));

      expect(receivedEvents.single, same(event));
    });
  });
}

final class _TestRecoveryContext extends FinancialPipelineContext {
  const _TestRecoveryContext({required this.operationId});

  final String operationId;
}
