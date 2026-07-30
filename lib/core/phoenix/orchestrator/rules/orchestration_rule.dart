import '../../../events/models/phoenix_event.dart';
import '../models/orchestration_result.dart';

abstract class OrchestrationRule {
  const OrchestrationRule();

  bool supports(PhoenixEvent event);

  Future<OrchestrationResult> execute(PhoenixEvent event);
}
