import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/settlement/'
    'settlement_domain_event.dart';

import 'package:mentora/core/financial/domain/settlement/'
    'settlement_id.dart';

import 'package:mentora/core/financial/events/settlement/'
    'settlement_event_handler.dart';

import 'package:mentora/core/financial/infrastructure/events/settlement/'
    'in_memory_settlement_event_dispatcher.dart';

void main() {
  group('InMemorySettlementEventDispatcher', () {
    late InMemorySettlementEventDispatcher dispatcher;

    setUp(() {
      dispatcher = InMemorySettlementEventDispatcher();
    });

    test('dispatches one event to one handler', () async {
      final handler = _ProcessingStartedHandler();

      dispatcher.register(handler);

      final event = SettlementProcessingStarted(
        settlementId: SettlementId('settlement_001'),
        occurredAt: DateTime.utc(2026, 7, 23),
      );

      await dispatcher.dispatch(event);

      expect(handler.callCount, 1);
      expect(handler.lastEvent, same(event));
    });

    test('dispatches one event to multiple handlers '
        'in registration order', () async {
      final executionOrder = <String>[];

      final handlerA = _OrderedProcessingStartedHandler(
        name: 'A',
        executionOrder: executionOrder,
      );

      final handlerB = _OrderedProcessingStartedHandler(
        name: 'B',
        executionOrder: executionOrder,
      );

      final handlerC = _OrderedProcessingStartedHandler(
        name: 'C',
        executionOrder: executionOrder,
      );

      dispatcher
        ..register(handlerA)
        ..register(handlerB)
        ..register(handlerC);

      final event = SettlementProcessingStarted(
        settlementId: SettlementId('settlement_ordered_dispatch_001'),
        occurredAt: DateTime.utc(2026, 7, 23),
      );

      await dispatcher.dispatch(event);

      expect(executionOrder, <String>['A', 'B', 'C']);

      expect(handlerA.callCount, 1);
      expect(handlerB.callCount, 1);
      expect(handlerC.callCount, 1);

      expect(handlerA.lastEvent, same(event));
      expect(handlerB.lastEvent, same(event));
      expect(handlerC.lastEvent, same(event));
    });

    test('does nothing when no handler is registered', () async {
      final event = SettlementProcessingStarted(
        settlementId: SettlementId('settlement_001'),
        occurredAt: DateTime.utc(2026, 7, 23),
      );

      await dispatcher.dispatch(event);

      expect(dispatcher.handlerCountFor(SettlementProcessingStarted), 0);
    });
  });
}

final class _ProcessingStartedHandler
    implements SettlementEventHandler<SettlementProcessingStarted> {
  int callCount = 0;

  SettlementProcessingStarted? lastEvent;

  @override
  Type get eventType => SettlementProcessingStarted;

  @override
  Future<void> handle(SettlementProcessingStarted event) async {
    callCount++;
    lastEvent = event;
  }
}

final class _OrderedProcessingStartedHandler
    implements SettlementEventHandler<SettlementProcessingStarted> {
  _OrderedProcessingStartedHandler({
    required this.name,
    required this.executionOrder,
  });

  final String name;
  final List<String> executionOrder;

  int callCount = 0;

  SettlementProcessingStarted? lastEvent;

  @override
  Type get eventType => SettlementProcessingStarted;

  @override
  Future<void> handle(SettlementProcessingStarted event) async {
    callCount++;
    lastEvent = event;
    executionOrder.add(name);
  }
}
