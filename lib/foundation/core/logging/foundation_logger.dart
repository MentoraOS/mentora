import 'package:flutter/foundation.dart';

/// Log severity, lowest to highest.
enum LogLevel { debug, info, warning, error }

/// The logging port of the foundation. Structure only — a log line
/// never carries business content or user data (the observability
/// invariant, applied to the client).
abstract interface class FoundationLogger {
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  });
}

/// Console adapter: debug builds print, release builds stay silent —
/// the future remote adapter will plug in behind the same port.
final class ConsoleFoundationLogger implements FoundationLogger {
  const ConsoleFoundationLogger();

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) {
      return;
    }
    final line = '[mentora/${level.name}] $message';
    debugPrint(error == null ? line : '$line | $error');
  }
}
