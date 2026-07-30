import 'financial_pipeline_context.dart';
import 'financial_pipeline_step.dart';

abstract interface class FinancialPipeline<
  TContext extends FinancialPipelineContext
> {
  /// Stable and unique identifier of the pipeline.
  String get id;

  /// Ordered list of steps executed by the pipeline engine.
  List<FinancialPipelineStep<TContext>> get steps;
}
