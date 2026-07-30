import '../runtime/automation_runtime_result.dart';

/// Result returned by the Automation Orchestrator.
final class AutomationOrchestrationResult {
  const AutomationOrchestrationResult({
    required this.runtimeResult,
    required this.startedAt,
    required this.completedAt,
  });

  /// Runtime execution result.
  final AutomationRuntimeResult runtimeResult;

  /// Orchestrator start timestamp.
  final DateTime startedAt;

  /// Orchestrator completion timestamp.
  final DateTime completedAt;

  /// Total orchestration duration.
  Duration get duration => completedAt.difference(startedAt);
}
