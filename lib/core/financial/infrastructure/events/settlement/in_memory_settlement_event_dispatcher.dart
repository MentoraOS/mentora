import '../../../domain/settlement/'
    'settlement_domain_event.dart';

import '../../../events/settlement/'
    'settlement_event_dispatcher.dart';

import '../../../events/settlement/'
    'settlement_event_handler.dart';

/// In-memory settlement event dispatcher.
///
/// Intended for:
/// - unit and integration tests;
/// - local development;
/// - synchronous in-process event handling.
///
/// Events and handlers are executed sequentially to preserve deterministic
/// ordering inside the Financial Core.
final class InMemorySettlementEventDispatcher
    implements SettlementEventDispatcher {
  final Map<Type, List<SettlementEventHandler<SettlementDomainEvent>>>
  _handlers = <Type, List<SettlementEventHandler<SettlementDomainEvent>>>{};

  /// Registers a handler for its declared event type.
  ///
  /// Multiple handlers may listen to the same event type.
  void register<TEvent extends SettlementDomainEvent>(
    SettlementEventHandler<TEvent> handler,
  ) {
    final handlers = _handlers.putIfAbsent(
      handler.eventType,
      () => <SettlementEventHandler<SettlementDomainEvent>>[],
    );

    if (handlers.contains(handler)) {
      throw StateError(
        'Settlement event handler '
        '"${handler.runtimeType}" is already registered '
        'for event type "${handler.eventType}".',
      );
    }

    handlers.add(_SettlementEventHandlerAdapter<TEvent>(handler));
  }

  /// Unregisters one previously registered handler.
  ///
  /// Returns true when the handler was found and removed.
  bool unregister<TEvent extends SettlementDomainEvent>(
    SettlementEventHandler<TEvent> handler,
  ) {
    final handlers = _handlers[handler.eventType];

    if (handlers == null) {
      return false;
    }

    final initialLength = handlers.length;

    handlers.removeWhere(
      (candidate) =>
          candidate is _SettlementEventHandlerAdapter<TEvent> &&
          identical(candidate.delegate, handler),
    );

    if (handlers.isEmpty) {
      _handlers.remove(handler.eventType);
    }

    return handlers.length < initialLength;
  }

  @override
  Future<void> dispatch(SettlementDomainEvent event) async {
    final handlers = _handlers[event.runtimeType];

    if (handlers == null || handlers.isEmpty) {
      return;
    }

    final snapshot =
        List<SettlementEventHandler<SettlementDomainEvent>>.unmodifiable(
          handlers,
        );

    for (final handler in snapshot) {
      await handler.handle(event);
    }
  }

  @override
  Future<void> dispatchAll(Iterable<SettlementDomainEvent> events) async {
    for (final event in events) {
      await dispatch(event);
    }
  }

  /// Returns the number of handlers registered for [eventType].
  int handlerCountFor(Type eventType) {
    return _handlers[eventType]?.length ?? 0;
  }

  /// Returns true when at least one handler is registered for [eventType].
  bool hasHandlersFor(Type eventType) {
    return handlerCountFor(eventType) > 0;
  }

  /// Removes every registered handler.
  void clear() {
    _handlers.clear();
  }
}

final class _SettlementEventHandlerAdapter<TEvent extends SettlementDomainEvent>
    implements SettlementEventHandler<SettlementDomainEvent> {
  const _SettlementEventHandlerAdapter(this.delegate);

  final SettlementEventHandler<TEvent> delegate;

  @override
  Type get eventType => delegate.eventType;

  @override
  Future<void> handle(SettlementDomainEvent event) {
    if (event is! TEvent) {
      throw StateError(
        'Settlement event handler '
        '"${delegate.runtimeType}" expected '
        '"$TEvent" but received '
        '"${event.runtimeType}".',
      );
    }

    return delegate.handle(event);
  }
}
