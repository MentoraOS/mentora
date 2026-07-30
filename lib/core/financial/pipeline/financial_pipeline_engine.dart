import 'financial_pipeline.dart';
import 'financial_pipeline_context.dart';
import 'financial_pipeline_result.dart';

abstract interface class FinancialPipelineEngine {
  Future<FinancialPipelineResult> execute<
    TContext extends FinancialPipelineContext
  >({required FinancialPipeline<TContext> pipeline, required TContext context});
}
