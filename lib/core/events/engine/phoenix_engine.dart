import '../../engines/base_engine.dart';

import '../listeners/notification_listener.dart';
import '../models/event.dart';
import '../repository/event_repository.dart';
import '../services/event_dispatcher.dart';
import '../../engines/engine_registry.dart';

class PhoenixEngine extends BaseEngine {
  PhoenixEngine._();

  static final PhoenixEngine _instance = PhoenixEngine._();

  static PhoenixEngine get instance => _instance;

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    EventDispatcher.register(NotificationListener());

    EngineRegistry.register(instance);

    _initialized = true;

    await super.initialize();
  }

  static void publish(Event event) {
    EventRepository.add(event);

    EventDispatcher.dispatch(event);
  }

  static List<Event> history() {
    return EventRepository.findAll();
  }

  static void clear() {
    EventRepository.clear();
  }
}
