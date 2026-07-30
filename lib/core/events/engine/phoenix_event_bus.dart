import '../listeners/phoenix_event_listener.dart';
import '../models/phoenix_event.dart';

class PhoenixEventBus {
  PhoenixEventBus._();

  static final List<PhoenixEventListener> _listeners = [];

  static void register(PhoenixEventListener listener) {
    _listeners.add(listener);
  }

  static void unregister(PhoenixEventListener listener) {
    _listeners.remove(listener);
  }

  static Future<void> publish(PhoenixEvent event) async {
    for (final listener in _listeners) {
      if (listener.supports(event)) {
        await listener.handle(event);
      }
    }
  }

  static void clear() {
    _listeners.clear();
  }
}
