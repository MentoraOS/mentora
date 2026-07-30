import 'package:mentora/core/automation/domain/automation.dart';
import 'package:mentora/core/automation/domain/automation_action.dart';
import 'package:mentora/core/automation/domain/automation_condition.dart';
import 'package:mentora/core/automation/domain/automation_id.dart';
import 'package:mentora/core/automation/domain/automation_status.dart';
import 'package:mentora/core/automation/domain/automation_trigger.dart';

final class AutomationTestFactory {
  const AutomationTestFactory._();

  static Automation create({
    String id = 'automation-test',
    String name = 'Test automation',
    int version = 1,
    AutomationStatus status = AutomationStatus.active,
    AutomationTrigger? trigger,
    List<AutomationCondition> conditions = const <AutomationCondition>[],
    List<AutomationAction>? actions,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    final DateTime resolvedCreatedAt =
        createdAt ?? DateTime.utc(2026, 1, 1, 10);

    return Automation(
      id: AutomationId(id),
      name: name,
      version: version,
      status: status,
      trigger: trigger ?? AutomationTrigger(type: 'manual'),
      conditions: conditions,
      actions:
          actions ?? <AutomationAction>[AutomationAction(type: 'test-action')],
      createdAt: resolvedCreatedAt,
      updatedAt: updatedAt ?? resolvedCreatedAt.add(const Duration(minutes: 5)),
      metadata: metadata,
    );
  }

  static AutomationAction action({
    String type = 'test-action',
    Map<String, Object?> configuration = const <String, Object?>{},
    bool continueOnFailure = false,
  }) {
    return AutomationAction(
      type: type,
      configuration: configuration,
      continueOnFailure: continueOnFailure,
    );
  }

  static AutomationCondition condition({
    String type = 'test-condition',
    Map<String, Object?> configuration = const <String, Object?>{},
    bool negated = false,
  }) {
    return AutomationCondition(
      type: type,
      configuration: configuration,
      negated: negated,
    );
  }

  static AutomationTrigger trigger({
    String type = 'manual',
    Map<String, Object?> configuration = const <String, Object?>{},
  }) {
    return AutomationTrigger(type: type, configuration: configuration);
  }
}
