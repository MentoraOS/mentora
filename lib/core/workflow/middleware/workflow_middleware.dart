import '../workflow.dart';
import '../workflow_context.dart';
import '../workflow_result.dart';

abstract class WorkflowMiddleware {
  const WorkflowMiddleware();

  Future<WorkflowResult<T>> handle<T>({
    required Workflow<T> workflow,
    required WorkflowContext context,
    required Future<WorkflowResult<T>> Function() next,
  });
}
