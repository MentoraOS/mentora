import 'log_destination.dart';
import 'mentora_log.dart';

class ConsoleDestination implements LogDestination {
  @override
  void write(MentoraLog log) {
    print(
      '[${log.level.name.toUpperCase()}]'
      ' [${log.engine}]'
      ' ${log.message}',
    );
  }
}
