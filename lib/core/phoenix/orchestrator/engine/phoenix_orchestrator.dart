import '../../../events/models/phoenix_event.dart';
import '../models/orchestration_result.dart';

import '../registry/orchestration_rule_registry.dart';

class PhoenixOrchestrator {
  final OrchestrationRuleRegistry registry;

  const PhoenixOrchestrator({required this.registry});

  Future<List<OrchestrationResult>> handle(PhoenixEvent event) async {
    final rule = registry.resolveRule(event.name);

    if (rule == null) {
      return [];
    }

    final result = await rule.execute(event);

    return [result];
  }
}
