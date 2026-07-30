import '../automation_module.dart';
import '../runtime/automation_runtime_result.dart';
import 'automation_orchestration_request.dart';
import 'automation_orchestration_result.dart';
import 'automation_orchestrator.dart';

/// Default implementation of [AutomationOrchestrator].
///
/// Responsibilities:
/// - ensure the Automation Core is initialized;
/// - delegate execution to the Automation Runtime;
/// - expose a stable orchestration API to application services.
///
/// This class intentionally contains no business logic.
final class DefaultAutomationOrchestrator implements AutomationOrchestrator {
  DefaultAutomationOrchestrator({
    required AutomationModule automationModule,
    DateTime Function()? clock,
  }) : _automationModule = automationModule,
       _clock = clock ?? DateTime.now;

  final AutomationModule _automationModule;
  final DateTime Function() _clock;

  @override
  Future<AutomationOrchestrationResult> orchestrate(
    AutomationOrchestrationRequest request,
  ) async {
    final DateTime startedAt = _utcNow();

    await _automationModule.initialize();

    final AutomationRuntimeResult runtimeResult = await _automationModule
        .runtime
        .execute(
          request.automationId,
          input: request.input,
          metadata: request.metadata,
        );

    return AutomationOrchestrationResult(
      runtimeResult: runtimeResult,
      startedAt: startedAt,
      completedAt: _safeCompletedAt(startedAt),
    );
  }

  DateTime _safeCompletedAt(DateTime startedAt) {
    final DateTime now = _utcNow();

    if (now.isBefore(startedAt)) {
      return startedAt;
    }

    return now;
  }

  DateTime _utcNow() => _clock().toUtc();
}
