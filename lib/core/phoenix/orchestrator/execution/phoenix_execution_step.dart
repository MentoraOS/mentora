import '../models/phoenix_execution_context.dart';

abstract class PhoenixExecutionStep<T extends PhoenixExecutionContext> {
  const PhoenixExecutionStep();

  Future<T> execute(T context);
}
