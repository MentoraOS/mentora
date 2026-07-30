import '../models/phoenix_event.dart';

abstract class PhoenixEventListener {
  const PhoenixEventListener();

  bool supports(PhoenixEvent event);

  Future<void> handle(PhoenixEvent event);
}
