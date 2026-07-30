import '../../events/listeners/phoenix_event_listener.dart';
import '../../events/models/phoenix_event.dart';

import '../engine/notification_engine.dart';
import '../factories/notification_factory.dart';
import '../registry/notification_strategy_registry.dart';

class BookingNotificationListener extends PhoenixEventListener {
  final NotificationEngine engine;
  final NotificationFactory factory;
  final NotificationStrategyRegistry registry;

  const BookingNotificationListener({
    required this.engine,
    required this.factory,
    required this.registry,
  });

  @override
  bool supports(PhoenixEvent event) {
    return event.name == 'booking.confirmed';
  }

  @override
  Future<void> handle(PhoenixEvent event) async {
    final notification = factory.fromEvent(event);

    if (notification == null) {
      return;
    }

    final strategy = registry.resolve(event.name);

    if (strategy == null) {
      return;
    }

    final notifications = await strategy.build(notification);

    for (final item in notifications) {
      await engine.create(item);
      await engine.send(item);
    }
  }
}
