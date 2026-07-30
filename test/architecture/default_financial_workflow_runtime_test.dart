import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_workflow.dart';
import 'package:mentora/core/financial/workflow/runtime/'
    'default_financial_workflow_runtime.dart';

void main() {
  group('DefaultFinancialWorkflowRuntime', () {
    test('should execute the supplied workflow exactly once', () async {
      final workflow = _RecordingFinancialWorkflow<int, String>(
        result: 'completed',
      );

      const runtime = DefaultFinancialWorkflowRuntime();

      final result = await runtime.execute(workflow: workflow, context: 125000);

      expect(result, 'completed');
      expect(workflow.executionCount, 1);
      expect(workflow.receivedContext, 125000);
    });

    test('should preserve the exact workflow result instance', () async {
      final expectedResult = _TestWorkflowResult(value: 125000);

      final workflow = _RecordingFinancialWorkflow<String, _TestWorkflowResult>(
        result: expectedResult,
      );

      const runtime = DefaultFinancialWorkflowRuntime();

      final result = await runtime.execute(
        workflow: workflow,
        context: 'consultation-001',
      );

      expect(result, same(expectedResult));
    });

    test('should preserve generic context and result types', () async {
      final context = _TestWorkflowContext(consultationId: 'consultation-001');

      final expectedResult = _TestWorkflowResult(value: 50000);

      final workflow =
          _RecordingFinancialWorkflow<
            _TestWorkflowContext,
            _TestWorkflowResult
          >(result: expectedResult);

      const runtime = DefaultFinancialWorkflowRuntime();

      final result = await runtime
          .execute<_TestWorkflowContext, _TestWorkflowResult>(
            workflow: workflow,
            context: context,
          );

      expect(workflow.receivedContext, same(context));
      expect(result, same(expectedResult));
    });

    test('should propagate workflow exceptions unchanged', () async {
      final expectedError = StateError('Workflow execution failed.');

      final workflow = _ThrowingFinancialWorkflow<String, int>(
        error: expectedError,
      );

      const runtime = DefaultFinancialWorkflowRuntime();

      final future = runtime.execute(
        workflow: workflow,
        context: 'consultation-001',
      );

      await expectLater(future, throwsA(same(expectedError)));
    });

    test('should preserve workflow exception stack trace', () async {
      final expectedError = StateError('Settlement failed.');

      final workflow = _ThrowingFinancialWorkflow<String, void>(
        error: expectedError,
      );

      const runtime = DefaultFinancialWorkflowRuntime();

      try {
        await runtime.execute(workflow: workflow, context: 'consultation-001');

        fail('The workflow exception should have propagated.');
      } catch (error, stackTrace) {
        expect(error, same(expectedError));
        expect(stackTrace, isNot(StackTrace.empty));
      }
    });
  });
}

final class _RecordingFinancialWorkflow<TContext, TResult>
    implements FinancialWorkflow<TContext, TResult> {
  _RecordingFinancialWorkflow({required this.result});

  final TResult result;

  int executionCount = 0;
  TContext? receivedContext;

  @override
  String get key => 'test.recording.workflow';

  @override
  Future<TResult> execute(TContext context) async {
    executionCount++;
    receivedContext = context;

    return result;
  }
}

final class _ThrowingFinancialWorkflow<TContext, TResult>
    implements FinancialWorkflow<TContext, TResult> {
  _ThrowingFinancialWorkflow({required this.error});

  final Object error;

  @override
  String get key => 'test.throwing.workflow';

  @override
  Future<TResult> execute(TContext context) async {
    throw error;
  }
}

final class _TestWorkflowContext {
  const _TestWorkflowContext({required this.consultationId});

  final String consultationId;
}

final class _TestWorkflowResult {
  const _TestWorkflowResult({required this.value});

  final int value;
}
