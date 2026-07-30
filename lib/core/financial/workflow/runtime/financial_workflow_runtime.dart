import '../../orchestrator/workflows/financial_workflow.dart';

abstract interface class FinancialWorkflowRuntime {
  Future<TResult> execute<TContext, TResult>({
    required FinancialWorkflow<TContext, TResult> workflow,

    required TContext context,
  });
}
