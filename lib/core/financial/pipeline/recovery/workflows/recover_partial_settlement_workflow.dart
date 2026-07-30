import '../contexts/'
    'partial_settlement_recovery_context.dart';

import '../pipeline/'
    'financial_recovery_pipeline.dart';

import '../strategies/'
    'financial_recovery_strategy_request.dart';
import '../strategies/'
    'financial_recovery_strategy_result.dart';
import '../strategies/'
    'recover_partial_settlement_strategy.dart';

import 'financial_recovery_workflow.dart';

/// Application-level workflow for recovering a partially posted settlement.
///
/// This workflow contains no settlement repair logic.
///
/// Its responsibilities are limited to:
/// - declaring the supported recovery pipeline;
/// - validating request compatibility;
/// - delegating execution to [FinancialRecoveryPipeline];
/// - returning the exact result produced by the pipeline.
final class RecoverPartialSettlementWorkflow
    implements FinancialRecoveryWorkflow<PartialSettlementRecoveryContext> {
  const RecoverPartialSettlementWorkflow({required this.pipeline});

  /// Stable registry identifier for this workflow.
  static const String workflowKeyValue = 'recover.partial.settlement.workflow';

  /// Pipeline identifier shared with the concrete recovery strategy.
  static const String supportedPipelineId =
      RecoverPartialSettlementStrategy.supportedPipelineId;

  final FinancialRecoveryPipeline pipeline;

  @override
  String get workflowKey => workflowKeyValue;

  @override
  String get pipelineId => supportedPipelineId;

  @override
  bool supports(
    FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext> request,
  ) {
    return request.pipelineId.trim() == supportedPipelineId;
  }

  @override
  Future<FinancialRecoveryStrategyResult> execute({
    required FinancialRecoveryStrategyRequest<PartialSettlementRecoveryContext>
    request,
  }) {
    return pipeline.execute(request: request);
  }
}
