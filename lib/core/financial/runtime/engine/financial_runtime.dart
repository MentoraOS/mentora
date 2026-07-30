import '../../pipeline/financial_pipeline.dart';
import '../../pipeline/financial_pipeline_context.dart';
import '../context/financial_runtime_execution_context.dart';
import '../result/financial_runtime_execution_result.dart';

abstract interface class FinancialRuntime {
  Future<FinancialRuntimeExecutionResult>
  execute<TContext extends FinancialPipelineContext>({
    required FinancialPipeline<TContext> pipeline,
    required FinancialRuntimeExecutionContext<TContext> executionContext,
  });
}
