import '../middleware/workflow_middleware.dart';

class WorkflowPipeline {
  final List<WorkflowMiddleware> middlewares;

  const WorkflowPipeline({this.middlewares = const []});
}
