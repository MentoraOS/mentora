import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/automation/domain/automation_execution.dart';
import 'package:mentora/core/automation/domain/automation_id.dart';

void main() {
  group('AutomationExecution', () {
    final DateTime startedAt = DateTime.utc(2026, 1, 1, 10);
    final DateTime completedAt = startedAt.add(const Duration(seconds: 2));

    test('creates a valid pending execution', () {
      final AutomationExecution execution = AutomationExecution(
        executionId: 'execution-001',
        automationId: AutomationId('automation-001'),
        automationVersion: 1,
        status: AutomationExecutionStatus.pending,
        startedAt: startedAt,
      );

      expect(execution.isTerminal, isFalse);
      expect(execution.completedAt, isNull);
    });

    test('creates a valid successful execution', () {
      final AutomationExecution execution = AutomationExecution(
        executionId: 'execution-001',
        automationId: AutomationId('automation-001'),
        automationVersion: 1,
        status: AutomationExecutionStatus.succeeded,
        startedAt: startedAt,
        completedAt: completedAt,
        output: <String, Object?>{'sent': true},
      );

      expect(execution.isTerminal, isTrue);
      expect(execution.isSuccessful, isTrue);
      expect(execution.hasFailed, isFalse);
    });

    test('rejects an empty execution identifier', () {
      expect(
        () => AutomationExecution(
          executionId: '   ',
          automationId: AutomationId('automation-001'),
          automationVersion: 1,
          status: AutomationExecutionStatus.pending,
          startedAt: startedAt,
        ),
        throwsArgumentError,
      );
    });

    test('rejects an automation version below one', () {
      expect(
        () => AutomationExecution(
          executionId: 'execution-001',
          automationId: AutomationId('automation-001'),
          automationVersion: 0,
          status: AutomationExecutionStatus.pending,
          startedAt: startedAt,
        ),
        throwsArgumentError,
      );
    });

    test('requires a completion date for terminal status', () {
      expect(
        () => AutomationExecution(
          executionId: 'execution-001',
          automationId: AutomationId('automation-001'),
          automationVersion: 1,
          status: AutomationExecutionStatus.succeeded,
          startedAt: startedAt,
        ),
        throwsArgumentError,
      );
    });

    test('rejects a completion date for non-terminal status', () {
      expect(
        () => AutomationExecution(
          executionId: 'execution-001',
          automationId: AutomationId('automation-001'),
          automationVersion: 1,
          status: AutomationExecutionStatus.running,
          startedAt: startedAt,
          completedAt: completedAt,
        ),
        throwsArgumentError,
      );
    });

    test('requires an error message for failed status', () {
      expect(
        () => AutomationExecution(
          executionId: 'execution-001',
          automationId: AutomationId('automation-001'),
          automationVersion: 1,
          status: AutomationExecutionStatus.failed,
          startedAt: startedAt,
          completedAt: completedAt,
        ),
        throwsArgumentError,
      );
    });

    test('normalizes a failure error message', () {
      final AutomationExecution execution = AutomationExecution(
        executionId: 'execution-001',
        automationId: AutomationId('automation-001'),
        automationVersion: 1,
        status: AutomationExecutionStatus.failed,
        startedAt: startedAt,
        completedAt: completedAt,
        errorMessage: '  Network failure  ',
      );

      expect(execution.errorMessage, 'Network failure');
      expect(execution.hasFailed, isTrue);
    });

    test('rejects a completion date before start date', () {
      expect(
        () => AutomationExecution(
          executionId: 'execution-001',
          automationId: AutomationId('automation-001'),
          automationVersion: 1,
          status: AutomationExecutionStatus.cancelled,
          startedAt: startedAt,
          completedAt: startedAt.subtract(const Duration(milliseconds: 1)),
        ),
        throwsArgumentError,
      );
    });

    test('protects input and output from mutation', () {
      final AutomationExecution execution = AutomationExecution(
        executionId: 'execution-001',
        automationId: AutomationId('automation-001'),
        automationVersion: 1,
        status: AutomationExecutionStatus.succeeded,
        startedAt: startedAt,
        completedAt: completedAt,
        input: <String, Object?>{'recipient': 'client@example.com'},
        output: <String, Object?>{'sent': true},
      );

      expect(
        () => execution.input['recipient'] = 'other@example.com',
        throwsUnsupportedError,
      );

      expect(() => execution.output['sent'] = false, throwsUnsupportedError);
    });
  });
}
