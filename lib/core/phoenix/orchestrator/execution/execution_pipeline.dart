import '../models/phoenix_execution_context.dart';
import 'phoenix_execution_step.dart';

class ExecutionPipeline<T extends PhoenixExecutionContext> {
  final List<PhoenixExecutionStep<T>> steps;

  const ExecutionPipeline({required this.steps});
}
