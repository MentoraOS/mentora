class ConfigurationManager {
  ConfigurationManager._();

  static bool _initialized = false;

  static bool get initialized => _initialized;

  static String environment = 'development';

  static Future<void> initialize() async {
    _initialized = true;
  }

  static bool get isDevelopment => environment == 'development';

  static bool get isProduction => environment == 'production';
}
