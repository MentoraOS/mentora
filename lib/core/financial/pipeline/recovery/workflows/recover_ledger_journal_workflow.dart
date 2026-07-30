import '../contexts/'
    'ledger_journal_posting_recovery_context.dart';

import '../pipeline/'
    'financial_recovery_pipeline.dart';

import '../strategies/'
    'financial_recovery_strategy_request.dart';
import '../strategies/'
    'financial_recovery_strategy_result.dart';
import '../strategies/'
    'recover_ledger_journal_posting_strategy.dart';

import 'financial_recovery_workflow.dart';

/// Application-level workflow for recovering a Ledger Journal posting.
final class RecoverLedgerJournalWorkflow
    implements FinancialRecoveryWorkflow<LedgerJournalPostingRecoveryContext> {
  const RecoverLedgerJournalWorkflow({required this.pipeline});

  static const String workflowKeyValue = 'recover.ledger.journal.workflow';

  static const String supportedPipelineId =
      RecoverLedgerJournalPostingStrategy.supportedPipelineId;

  final FinancialRecoveryPipeline pipeline;

  @override
  String get workflowKey => workflowKeyValue;

  @override
  String get pipelineId => supportedPipelineId;

  @override
  bool supports(
    FinancialRecoveryStrategyRequest<LedgerJournalPostingRecoveryContext>
    request,
  ) {
    return request.pipelineId.trim() == supportedPipelineId;
  }

  @override
  Future<FinancialRecoveryStrategyResult> execute({
    required FinancialRecoveryStrategyRequest<
      LedgerJournalPostingRecoveryContext
    >
    request,
  }) {
    return pipeline.execute(request: request);
  }
}
