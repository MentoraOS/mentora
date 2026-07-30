import '../domain/automation_execution.dart';
import '../domain/automation_id.dart';

/// Repository responsible for persisting automation execution history.
///
/// This repository is intended for audit logs, monitoring, retries,
/// reporting, analytics and observability.
abstract interface class AutomationExecutionRepository {
  /// Creates or updates an execution record.
  Future<void> save(AutomationExecution execution);

  /// Returns an execution by its identifier.
  ///
  /// Returns null if it does not exist.
  Future<AutomationExecution?> findById(String executionId);

  /// Returns every execution belonging to an automation.
  Future<List<AutomationExecution>> findByAutomationId(
    AutomationId automationId,
  );

  /// Returns the latest executions.
  Future<List<AutomationExecution>> findRecent({int limit = 50});

  /// Returns true if an execution exists.
  Future<bool> exists(String executionId);

  /// Deletes an execution.
  ///
  /// Returns true if an execution was removed.
  Future<bool> delete(String executionId);
}
