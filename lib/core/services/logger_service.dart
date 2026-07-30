class LoggerService {
  void info(String message) {
    print('[INFO] $message');
  }

  void warning(String message) {
    print('[WARNING] $message');
  }

  void error(String message) {
    print('[ERROR] $message');
  }
}
