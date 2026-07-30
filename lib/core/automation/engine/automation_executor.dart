import '../domain/automation_action.dart';
import 'automation_execution_context.dart';

/// Executes one automation action.
abstract interface class AutomationExecutor {
  String get actionType;

  Future<Map<String, Object?>> execute({
    required AutomationAction action,
    required AutomationExecutionContext context,
  });
}
