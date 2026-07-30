import 'logger.dart';
import 'configuration_manager.dart';

class MentoraBootstrap {
  MentoraBootstrap._();

  static bool _initialized = false;

  static bool get initialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;

    AppLogger.info('🚀 Mentora OS Bootstrap');

    await ConfigurationManager.initialize();

    _registerCoreServices();

    _initialized = true;

    AppLogger.info('✅ Mentora OS Ready');
  }

  static void _registerCoreServices() {
    AppLogger.info('Registering Foundation services...');
  }
}
