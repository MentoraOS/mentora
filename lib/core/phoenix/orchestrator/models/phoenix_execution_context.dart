import '../../../events/models/phoenix_event.dart';

abstract class PhoenixExecutionContext {
  final PhoenixEvent event;

  const PhoenixExecutionContext({required this.event});
  PhoenixExecutionContext copyWith({PhoenixEvent? event});
}
