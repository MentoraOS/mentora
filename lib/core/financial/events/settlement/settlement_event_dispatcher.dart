import '../../domain/settlement/'
    'settlement_domain_event.dart';

/// Dispatches persisted settlement domain events to registered handlers.
///
/// The dispatcher belongs to the application boundary. Concrete
/// implementations may dispatch in memory or through an external event bus.
abstract interface class SettlementEventDispatcher {
  /// Dispatches one event.
  Future<void> dispatch(SettlementDomainEvent event);

  /// Dispatches events sequentially in their original aggregate order.
  Future<void> dispatchAll(Iterable<SettlementDomainEvent> events);
}
