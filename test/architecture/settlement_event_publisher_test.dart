import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/settlement/'
    'settlement_domain_event.dart';

import 'package:mentora/core/financial/domain/settlement/'
    'settlement_id.dart';

import 'package:mentora/core/financial/events/settlement/'
    'settlement_event_dispatcher.dart';

import 'package:mentora/core/financial/events/settlement/'
    'settlement_event_publisher.dart';

void main() {
  group('SettlementEventPublisher', () {
    late _RecordingDispatcher dispatcher;
    late SettlementEventPublisher publisher;

    setUp(() {
      dispatcher = _RecordingDispatcher();

      publisher = SettlementEventPublisher(dispatcher: dispatcher);
    });

    test('publishes every event in order', () async {
      final events = <SettlementDomainEvent>[
        SettlementProcessingStarted(
          settlementId: SettlementId('settlement_001'),
          occurredAt: DateTime.utc(2026, 7, 23),
        ),
        SettlementCompleted(
          settlementId: SettlementId('settlement_001'),
          occurredAt: DateTime.utc(2026, 7, 23, 12),
        ),
      ];

      await publisher.publish(events);

      expect(dispatcher.dispatchedEvents, orderedEquals(events));
    });

    test('publishes nothing for an empty collection', () async {
      await publisher.publish(const <SettlementDomainEvent>[]);

      expect(dispatcher.dispatchedEvents, isEmpty);
    });
  });
}

final class _RecordingDispatcher implements SettlementEventDispatcher {
  final List<SettlementDomainEvent> dispatchedEvents = [];

  @override
  Future<void> dispatch(SettlementDomainEvent event) async {
    dispatchedEvents.add(event);
  }

  @override
  Future<void> dispatchAll(Iterable<SettlementDomainEvent> events) async {
    for (final event in events) {
      await dispatch(event);
    }
  }
}
