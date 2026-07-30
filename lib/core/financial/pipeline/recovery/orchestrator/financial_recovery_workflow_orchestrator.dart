import '../../financial_pipeline_context.dart';

import '../registry/'
    'financial_recovery_workflow_registry.dart';

import '../strategies/'
    'financial_recovery_strategy_request.dart';
import '../strategies/'
    'financial_recovery_strategy_result.dart';

/// Application-level orchestrator for financial recovery workflows.
///
/// This orchestrator is the public execution boundary above the Recovery
/// Workflow Registry.
///
/// Responsibilities:
/// - receive a typed recovery request;
/// - resolve the compatible workflow from the registry;
/// - execute that workflow exactly once;
/// - return the exact result produced by the workflow.
///
/// It must not:
/// - select a recovery strategy directly;
/// - access the strategy registry;
/// - access Ledger repositories;
/// - execute the Recovery Engine directly;
/// - transform controlled recovery results;
/// - swallow technical exceptions.
final class FinancialRecoveryWorkflowOrchestrator {
  const FinancialRecoveryWorkflowOrchestrator({required this.workflowRegistry});

  final FinancialRecoveryWorkflowRegistry workflowRegistry;

  /// Executes the workflow responsible for [request].
  ///
  /// Throws [StateError] when no registered workflow supports the request.
  ///
  /// Any exception produced by the selected workflow is propagated unchanged.
  Future<FinancialRecoveryStrategyResult> recover<
    TContext extends FinancialPipelineContext
  >({required FinancialRecoveryStrategyRequest<TContext> request}) async {
    final workflow = workflowRegistry.resolveRequired<TContext>(request);

    return await workflow.execute(request: request);
  }

  /// Returns whether a compatible workflow currently exists for [request].
  ///
  /// This method performs resolution only. It never executes the workflow.
  bool canRecover<TContext extends FinancialPipelineContext>(
    FinancialRecoveryStrategyRequest<TContext> request,
  ) {
    return workflowRegistry.resolve<TContext>(request) != null;
  }
}
