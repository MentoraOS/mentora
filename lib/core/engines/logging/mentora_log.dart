import 'log_level.dart';

class MentoraLog {
  final LogLevel level;
  final String engine;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const MentoraLog({
    required this.level,
    required this.engine,
    required this.message,
    required this.timestamp,
    this.metadata,
  });
}
