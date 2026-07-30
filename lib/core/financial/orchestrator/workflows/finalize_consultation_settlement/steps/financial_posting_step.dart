import '../../../../pipeline/pipeline.dart';

import '../../financial_posting/factories/'
    'settlement_posting_instruction_factory.dart';
import '../../financial_posting/financial_posting_context.dart';
import '../../financial_posting/financial_posting_workflow.dart';
import '../../settle_consultation/settle_consultation_workflow.dart';

import '../finalize_consultation_settlement_workflow.dart';
import '../pipeline/finalize_consultation_settlement_context.dart';

/// Converts the validated domain settlement into a Ledger-ready instruction
/// and executes the financial posting workflow.
///
/// The legacy split is temporarily forwarded during the migration of the
/// posting workflow and its adapters.
final class FinancialPostingStep
    implements FinancialPipelineStep<FinalizeConsultationSettlementContext> {
  const FinancialPostingStep({
    required FinancialPostingWorkflow workflow,
    SettlementPostingInstructionFactory instructionFactory =
        const SettlementPostingInstructionFactory(),
  }) : _workflow = workflow,
       _instructionFactory = instructionFactory;

  final FinancialPostingWorkflow _workflow;
  final SettlementPostingInstructionFactory _instructionFactory;

  @override
  String get id => 'post-consultation-settlement';

  @override
  Future<void> execute(FinalizeConsultationSettlementContext context) async {
    final split = context.split;

    if (split == null) {
      throw StateError(
        'Cannot post the consultation settlement before '
        'its financial split has been calculated.',
      );
    }

    final settlement = context.settlement;

    if (settlement == null) {
      throw StateError(
        'Cannot post the consultation settlement before '
        'its domain settlement has been built.',
      );
    }

    final input = context.settlementContext;

    final postingMetadata = <String, Object?>{
      ...input.metadata,
      'paymentId': input.paymentId.trim(),
      'settlementWorkflowKey': SettleConsultationWorkflow.workflowKey,
      'finalizeWorkflowKey': FinalizeConsultationSettlementWorkflow.workflowKey,
    };

    final instruction = _instructionFactory.create(
      settlement: settlement,
      operationId: input.operationId.trim(),
      consultationId: input.consultationId.trim(),
      escrowId: input.escrowId.trim(),
      clientId: input.clientId.trim(),
      expertId: input.expertId.trim(),
      occurredAt: input.occurredAt.toUtc(),
      metadata: postingMetadata,
    );

    context.postingResult = await _workflow.execute(
      FinancialPostingContext(
        operationId: instruction.operationId,
        consultationId: instruction.consultationId,
        escrowId: instruction.escrowId,
        clientId: instruction.clientId,
        expertId: instruction.expertId,

        // Temporary compatibility field for the legacy posting workflow.
        instruction: instruction,
        occurredAt: instruction.occurredAt,
        metadata: Map<String, dynamic>.from(instruction.metadata),
      ),
    );
  }
}
