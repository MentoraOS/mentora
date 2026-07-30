import '../models/phoenix_execution_context.dart';
import 'execution_pipeline.dart';

class PhoenixExecutionEngine<T extends PhoenixExecutionContext> {
  const PhoenixExecutionEngine();

  Future<T> execute(ExecutionPipeline<T> pipeline, T context) async {
    var currentContext = context;

    for (final step in pipeline.steps) {
      currentContext = await step.execute(currentContext);
    }

    return currentContext;
  }
}
