import '../domain/automation_id.dart';
import 'automation_runtime_result.dart';

abstract interface class AutomationRuntime {
  Future<AutomationRuntimeResult> execute(
    AutomationId automationId, {
    Map<String, Object?> input = const <String, Object?>{},
    Map<String, Object?> metadata = const <String, Object?>{},
  });
}
