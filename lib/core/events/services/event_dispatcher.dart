import '../listeners/base_event_listener.dart';
import '../models/event.dart';
import '../filters/event_filter.dart';

class EventDispatcher {
  EventDispatcher._();

  static final List<BaseEventListener> _listeners = [];

  static void register(BaseEventListener listener) {
    _listeners.add(listener);
  }

  static void unregister(BaseEventListener listener) {
    _listeners.remove(listener);
  }

  static void dispatch(Event event) {
    for (final listener in _listeners) {
      if (listener is EventFilter) {
        final filter = listener as EventFilter;

        if (filter.supportedEvents.contains(event.type)) {
          listener.handle(event);
        }
      }
    }
  }

  static void clear() {
    _listeners.clear();
  }
}
