import 'logger.dart';

class MentoraKernel {
  MentoraKernel._();

  static bool _running = false;

  static bool get isRunning => _running;

  static Future<void> start() async {
    if (_running) return;

    AppLogger.info('Starting Mentora Kernel...');

    _running = true;

    AppLogger.info('Mentora Kernel started.');
  }

  static Future<void> stop() async {
    if (!_running) return;

    AppLogger.info('Stopping Mentora Kernel...');

    _running = false;

    AppLogger.info('Mentora Kernel stopped.');
  }
}
