import 'mentora_log.dart';

abstract class LogDestination {
  void write(MentoraLog log);
}
