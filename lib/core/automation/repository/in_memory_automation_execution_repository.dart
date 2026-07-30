import 'dart:collection';

import '../domain/automation_execution.dart';
import '../domain/automation_id.dart';
import 'automation_execution_repository.dart';

/// In-memory implementation of [AutomationExecutionRepository].
///
/// Intended for:
/// - unit and architecture tests;
/// - local development;
/// - the first AutomationModule bootstrap.
///
/// Executions are indexed by [AutomationExecution.executionId] and their
/// insertion order is preserved.
final class InMemoryAutomationExecutionRepository
    implements AutomationExecutionRepository {
  InMemoryAutomationExecutionRepository({
    Iterable<AutomationExecution> executions = const <AutomationExecution>[],
  }) {
    for (final AutomationExecution execution in executions) {
      _executions[execution.executionId] = execution;
    }
  }

  final LinkedHashMap<String, AutomationExecution> _executions =
      LinkedHashMap<String, AutomationExecution>();

  @override
  Future<void> save(AutomationExecution execution) async {
    _executions[execution.executionId] = execution;
  }

  @override
  Future<AutomationExecution?> findById(String executionId) async {
    final String normalizedExecutionId = _normalizeExecutionId(executionId);

    return _executions[normalizedExecutionId];
  }

  @override
  Future<List<AutomationExecution>> findByAutomationId(
    AutomationId automationId,
  ) async {
    return List<AutomationExecution>.unmodifiable(
      _executions.values.where(
        (AutomationExecution execution) =>
            execution.automationId == automationId,
      ),
    );
  }

  @override
  Future<List<AutomationExecution>> findRecent({int limit = 50}) async {
    if (limit < 1) {
      throw ArgumentError.value(
        limit,
        'limit',
        'The recent execution limit must be greater than or equal to 1.',
      );
    }

    final List<AutomationExecution> orderedExecutions =
        _executions.values.toList(growable: false)..sort(
          (AutomationExecution left, AutomationExecution right) =>
              right.startedAt.compareTo(left.startedAt),
        );

    return List<AutomationExecution>.unmodifiable(
      orderedExecutions.take(limit),
    );
  }

  @override
  Future<bool> exists(String executionId) async {
    final String normalizedExecutionId = _normalizeExecutionId(executionId);

    return _executions.containsKey(normalizedExecutionId);
  }

  @override
  Future<bool> delete(String executionId) async {
    final String normalizedExecutionId = _normalizeExecutionId(executionId);

    return _executions.remove(normalizedExecutionId) != null;
  }

  /// Removes every persisted execution record.
  ///
  /// This operation is intentionally outside the repository contract because
  /// it is mainly useful for tests and local lifecycle management.
  Future<void> clear() async {
    _executions.clear();
  }

  /// Number of persisted executions.
  int get length => _executions.length;

  bool get isEmpty => _executions.isEmpty;

  bool get isNotEmpty => _executions.isNotEmpty;

  static String _normalizeExecutionId(String value) {
    final String normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        'executionId',
        'The automation execution identifier must not be empty.',
      );
    }

    return normalized;
  }
}
