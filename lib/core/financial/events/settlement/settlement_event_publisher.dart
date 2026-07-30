import '../../domain/settlement/'
    'settlement_domain_event.dart';

import 'settlement_event_dispatcher.dart';

/// Publishes settlement domain events through a dispatcher.
///
/// This component belongs to the application boundary. It does not persist
/// aggregates and must only be invoked after the related aggregate state has
/// been saved successfully.
final class SettlementEventPublisher {
  const SettlementEventPublisher({
    required SettlementEventDispatcher dispatcher,
  }) : _dispatcher = dispatcher;

  final SettlementEventDispatcher _dispatcher;

  /// Publishes settlement domain events sequentially in aggregate order.
  ///
  /// An empty event collection is accepted and produces no side effect.
  Future<void> publish(Iterable<SettlementDomainEvent> events) async {
    await _dispatcher.dispatchAll(events);
  }
}
