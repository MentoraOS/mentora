import '../../../events/listeners/phoenix_event_listener.dart';
import '../../../events/models/phoenix_event.dart';

import '../engine/phoenix_orchestrator.dart';

class PhoenixOrchestratorListener extends PhoenixEventListener {
  final PhoenixOrchestrator orchestrator;

  const PhoenixOrchestratorListener({required this.orchestrator});

  @override
  bool supports(PhoenixEvent event) {
    return true;
  }

  @override
  Future<void> handle(PhoenixEvent event) async {
    await orchestrator.handle(event);
  }
}
