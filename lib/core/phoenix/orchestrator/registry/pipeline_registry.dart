import '../execution/execution_pipeline.dart';
import '../models/phoenix_execution_context.dart';

class PipelineRegistry {
  final Map<String, ExecutionPipeline<dynamic>> _pipelines = {};

  void registerPipeline<T extends PhoenixExecutionContext>(
    String event,
    ExecutionPipeline<T> pipeline,
  ) {
    _pipelines[event] = pipeline;
  }

  ExecutionPipeline<T> resolve<T extends PhoenixExecutionContext>(
    String event,
  ) {
    final pipeline = _pipelines[event];

    if (pipeline == null) {
      throw StateError('No pipeline registered for event: $event');
    }

    if (pipeline is! ExecutionPipeline<T>) {
      throw StateError('Pipeline registered for $event does not support $T');
    }

    return pipeline;
  }

  bool supports(String event) {
    return _pipelines.containsKey(event);
  }

  void unregister(String event) {
    _pipelines.remove(event);
  }

  void clear() {
    _pipelines.clear();
  }
}
