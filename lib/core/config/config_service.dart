enum Environment { development, staging, production }

class ConfigService {
  ConfigService();

  Environment environment = Environment.development;

  bool debugMode = true;

  String appName = 'Mentora';

  String appVersion = '1.0.0';

  String apiBaseUrl = '';

  bool aiEnabled = true;

  bool analyticsEnabled = true;

  bool notificationsEnabled = true;

  bool paymentsEnabled = true;
}
