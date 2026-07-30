import 'business_pipeline_step.dart';

class BusinessPipeline<TContext> {
  final String name;
  final List<BusinessPipelineStep<TContext>> steps;

  const BusinessPipeline({required this.name, required this.steps});

  Future<void> run(TContext context) async {
    for (final step in steps) {
      await step.execute(context);
    }
  }
}
