import '../../domain/settlement/'
    'settlement_domain_event.dart';

/// Handles one concrete settlement domain event.
///
/// Implementations should remain focused on one responsibility:
/// audit, notification, analytics, billing, webhook, etc.
abstract interface class SettlementEventHandler<
  TEvent extends SettlementDomainEvent
> {
  /// Event type supported by this handler.
  Type get eventType;

  /// Handles a settlement domain event.
  Future<void> handle(TEvent event);
}
