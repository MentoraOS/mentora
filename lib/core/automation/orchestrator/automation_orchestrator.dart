import 'automation_orchestration_request.dart';
import 'automation_orchestration_result.dart';

/// High-level orchestration API for the Automation Core.
///
/// The orchestrator coordinates automation execution while remaining
/// independent from the underlying runtime implementation.
///
/// Application services should depend on this interface rather than
/// interacting with the runtime directly.
abstract interface class AutomationOrchestrator {
  /// Executes an automation orchestration request.
  Future<AutomationOrchestrationResult> orchestrate(
    AutomationOrchestrationRequest request,
  );
}
