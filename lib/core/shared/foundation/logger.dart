class AppLogger {
  AppLogger._();

  static void info(String message) {
    print('[INFO] $message');
  }

  static void warning(String message) {
    print('[WARNING] $message');
  }

  static void error(
    String message, {
    Object? exception,
    StackTrace? stackTrace,
  }) {
    print('[ERROR] $message');

    if (exception != null) {
      print(exception);
    }

    if (stackTrace != null) {
      print(stackTrace);
    }
  }
}
