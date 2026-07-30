import 'mentora_log.dart';
import 'log_level.dart';

class LoggerEngine {
  LoggerEngine._();

  static void log({
    required LogLevel level,
    required String engine,
    required String message,
    Map<String, dynamic>? metadata,
  }) {
    final log = MentoraLog(
      level: level,
      engine: engine,
      message: message,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    _write(log);
  }

  static void _write(MentoraLog log) {
    // Temporairement, on affiche dans la console.
    // Plus tard :
    // Firebase Crashlytics
    // Sentry
    // Datadog
    // Azure Monitor
    // AWS CloudWatch
    print(
      '[${log.level.name.toUpperCase()}] '
      '[${log.engine}] '
      '${log.message}',
    );
  }
}
