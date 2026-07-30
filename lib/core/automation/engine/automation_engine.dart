import '../domain/automation_status.dart';
import 'automation_execution_context.dart';
import 'automation_execution_result.dart';
import 'automation_executor.dart';

/// Coordinates the sequential execution of an automation's actions.
final class AutomationEngine {
  AutomationEngine({
    required Iterable<AutomationExecutor> executors,
    DateTime Function()? clock,
  }) : _executors = Map.unmodifiable(_indexExecutors(executors)),
       _clock = clock ?? DateTime.now;

  final Map<String, AutomationExecutor> _executors;
  final DateTime Function() _clock;

  Future<AutomationExecutionResult> execute(
    AutomationExecutionContext context,
  ) async {
    final automation = context.automation;

    if (automation.status != AutomationStatus.active) {
      return AutomationExecutionSkipped(
        executionId: context.executionId,
        startedAt: context.startedAt,
        completedAt: _utcNow(),
        reason: 'Automation is not active.',
      );
    }

    final output = <String, Object?>{};

    try {
      for (var index = 0; index < automation.actions.length; index++) {
        final action = automation.actions[index];
        final executor = _executors[action.type];

        if (executor == null) {
          throw StateError(
            'No automation executor is registered for action type '
            '"${action.type}".',
          );
        }

        try {
          final actionOutput = await executor.execute(
            action: action,
            context: context,
          );

          output['action.$index'] = Map.unmodifiable(actionOutput);
        } catch (error) {
          if (!action.continueOnFailure) {
            rethrow;
          }

          output['action.$index.error'] = error.toString();
        }
      }

      return AutomationExecutionSuccess(
        executionId: context.executionId,
        startedAt: context.startedAt,
        completedAt: _utcNow(),
        output: output,
      );
    } catch (error, stackTrace) {
      return AutomationExecutionFailure(
        executionId: context.executionId,
        startedAt: context.startedAt,
        completedAt: _utcNow(),
        error: error,
        stackTrace: stackTrace,
        metadata: <String, Object?>{
          'automationId': automation.id.value,
          'automationVersion': automation.version,
          'attempt': context.attempt,
        },
      );
    }
  }

  DateTime _utcNow() => _clock().toUtc();

  static Map<String, AutomationExecutor> _indexExecutors(
    Iterable<AutomationExecutor> executors,
  ) {
    final indexedExecutors = <String, AutomationExecutor>{};

    for (final executor in executors) {
      final actionType = _normalizeActionType(executor.actionType);

      if (indexedExecutors.containsKey(actionType)) {
        throw ArgumentError(
          'Multiple automation executors are registered for action type '
          '"$actionType".',
        );
      }

      indexedExecutors[actionType] = executor;
    }

    return indexedExecutors;
  }

  static String _normalizeActionType(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        'actionType',
        'The executor action type must not be empty.',
      );
    }

    return normalizedValue;
  }
}
