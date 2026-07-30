import 'workflow.dart';
import 'workflow_context.dart';
import 'workflow_execution.dart';
import 'workflow_result.dart';
import 'workflow_state.dart';
import 'workflow_event.dart';

class WorkflowEngine {
  WorkflowEngine._();

  static Future<WorkflowResult<T>> execute<T>({
    required Workflow<T> workflow,
    required WorkflowContext context,
  }) async {
    var execution = WorkflowExecution(
      id: 'wf_${DateTime.now().millisecondsSinceEpoch}',
      workflowName: workflow.name,
      context: context,
      state: WorkflowState.created,
      startedAt: DateTime.now(),
    );

    try {
      execution = execution.copyWith(state: WorkflowState.running);

      execution = execution.addEvent(
        WorkflowEvent(
          name: 'workflow.started',
          workflowName: workflow.name,
          userId: context.userId,
          workspaceId: context.workspaceId,
          occurredAt: DateTime.now(),
        ),
      );

      final result = await workflow.execute(context);

      execution = execution.copyWith(
        state: result.state,
        completedAt: DateTime.now(),
      );
      execution = execution.addEvent(
        WorkflowEvent(
          name: 'workflow.completed',
          workflowName: workflow.name,
          userId: context.userId,
          workspaceId: context.workspaceId,
          occurredAt: DateTime.now(),
        ),
      );

      return result;
    } catch (e) {
      execution = execution.copyWith(
        state: WorkflowState.failed,
        completedAt: DateTime.now(),
      );
      execution = execution.addEvent(
        WorkflowEvent(
          name: 'workflow.failed',
          workflowName: workflow.name,
          userId: context.userId,
          workspaceId: context.workspaceId,
          occurredAt: DateTime.now(),
          metadata: {'error': e.toString()},
        ),
      );

      return WorkflowResult.failure(message: e.toString());
    }
  }
}
