import 'mentora_event.dart';

typedef EventListener = void Function(MentoraEvent event);

class EventEngine {
  EventEngine._();

  static final Map<String, List<EventListener>> _listeners = {};

  static void subscribe(String eventName, EventListener listener) {
    _listeners.putIfAbsent(eventName, () => []);
    _listeners[eventName]!.add(listener);
  }

  static void unsubscribe(String eventName, EventListener listener) {
    _listeners[eventName]?.remove(listener);
  }

  static void publish(MentoraEvent event) {
    final listeners = _listeners[event.name] ?? [];

    for (final listener in listeners) {
      listener(event);
    }
  }

  static void clear() {
    _listeners.clear();
  }
}
