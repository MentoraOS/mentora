import '../../../financial/domain/settlement/settlement_domain_event.dart';
import 'settlement_event_dispatcher.dart';
import 'settlement_event_handler.dart';

/// Dispatches settlement domain events to matching in-memory handlers.
///
/// Handlers are executed sequentially in their registration order.
/// A handler receives an event only when its [eventType] matches the
/// concrete runtime type of that event.
final class InMemorySettlementEventDispatcher
    implements SettlementEventDispatcher {
  InMemorySettlementEventDispatcher({
    required Iterable<SettlementEventHandler<SettlementDomainEvent>> handlers,
  }) : _handlers = List.unmodifiable(handlers);

  final List<SettlementEventHandler<SettlementDomainEvent>> _handlers;

  @override
  Future<void> dispatch(SettlementDomainEvent event) async {
    final matchingHandlers = _handlers.where(
      (handler) => handler.eventType == event.runtimeType,
    );

    for (final handler in matchingHandlers) {
      await handler.handle(event);
    }
  }

  @override
  Future<void> dispatchAll(Iterable<SettlementDomainEvent> events) async {
    for (final event in events) {
      await dispatch(event);
    }
  }
}
