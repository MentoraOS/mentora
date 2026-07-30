abstract class BusinessPipelineStep<TContext> {
  const BusinessPipelineStep();

  String get name;

  Future<void> execute(TContext context);
}
