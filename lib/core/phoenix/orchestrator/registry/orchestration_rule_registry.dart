import '../../../events/registry/phoenix_registry.dart';
import '../rules/orchestration_rule.dart';

class OrchestrationRuleRegistry extends PhoenixRegistry<OrchestrationRule> {
  void registerRule(String event, OrchestrationRule rule) {
    register(event, rule);
  }

  OrchestrationRule? resolveRule(String event) {
    return resolve(event);
  }
}
