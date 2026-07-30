import '../engines/engine_registry.dart';
import '../engines/engine_state.dart';
import '../events/engine/phoenix_engine.dart';
import '../di/service_locater.dart';
import '../services/logger_service.dart';
import '../config/config_service.dart';
import '../identity/engine/authentication_engine.dart';
import '../enterprise/engine/atlas_engine.dart';

class MentoraOS {
  MentoraOS._();

  static bool _initialized = false;
  static bool _running = false;

  static bool get initialized => _initialized;
  static bool get isRunning => _running;

  static Future<void> initialize() async {
    if (_initialized) return;

    ServiceLocator.setup();

    final logger = ServiceLocator.get<LoggerService>();
    logger.info('Mentora OS initialized');

    final config = ServiceLocator.get<ConfigService>();

    logger.info('Environment : ${config.environment.name}');

    logger.info('Version : ${config.appVersion}');
    await AuthenticationEngine.instance.initialize();
    await PhoenixEngine.instance.initialize();
    await AtlasEngine.instance.initialize();

    _initialized = true;
  }

  static Future<void> start() async {
    if (_running) return;

    for (final engine in EngineRegistry.all()) {
      if (engine.state == EngineState.initialized) {
        await engine.start();
      }
    }

    _running = true;
  }

  static Future<void> stop() async {
    if (!_running) return;

    for (final engine in EngineRegistry.all().reversed) {
      await engine.stop();
    }

    _running = false;
  }

  static List<String> engineStates() {
    return EngineRegistry.all().map((engine) => engine.state.name).toList();
  }
}
