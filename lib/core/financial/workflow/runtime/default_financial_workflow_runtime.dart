import '../../orchestrator/workflows/financial_workflow.dart';
import 'financial_workflow_runtime.dart';

/// Default implementation of [FinancialWorkflowRuntime].
///
/// This first implementation intentionally delegates execution to the
/// supplied [FinancialWorkflow].
///
/// It introduces a stable workflow execution boundary without duplicating:
///
/// - workflow business logic;
/// - financial pipeline execution;
/// - transaction handling;
/// - ledger posting;
/// - recovery behavior.
///
/// Future workflow-level observability and execution policies may be added
/// behind this implementation without changing callers.
final class DefaultFinancialWorkflowRuntime
    implements FinancialWorkflowRuntime {
  const DefaultFinancialWorkflowRuntime();

  @override
  Future<TResult> execute<TContext, TResult>({
    required FinancialWorkflow<TContext, TResult> workflow,
    required TContext context,
  }) {
    return workflow.execute(context);
  }
}
