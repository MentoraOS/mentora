import '../../financial_pipeline_context.dart';

import '../strategies/'
    'financial_recovery_strategy_request.dart';
import '../strategies/'
    'financial_recovery_strategy_result.dart';

/// Application-level execution contract for one financial recovery workflow.
///
/// A recovery workflow represents a stable use-case entry point above the
/// Recovery Pipeline.
///
/// Responsibilities:
/// - declare the recovery pipeline it supports;
/// - receive a typed recovery request;
/// - delegate execution to the Recovery Pipeline;
/// - return the exact recovery result.
///
/// It must not:
/// - select a recovery strategy directly;
/// - access the strategy registry directly;
/// - contain Ledger repair logic;
/// - duplicate the Recovery Engine.
abstract interface class FinancialRecoveryWorkflow<
  TContext extends FinancialPipelineContext
> {
  /// Stable identifier used by the workflow registry.
  String get workflowKey;

  /// Pipeline identifier supported by this workflow.
  String get pipelineId;

  /// Returns whether this workflow can execute [request].
  ///
  /// The default implementations we create later will normally compare the
  /// request pipeline identifier with [pipelineId].
  bool supports(FinancialRecoveryStrategyRequest<TContext> request);

  /// Executes one recovery use case.
  Future<FinancialRecoveryStrategyResult> execute({
    required FinancialRecoveryStrategyRequest<TContext> request,
  });
}
