import '../../../../domain/settlement/settlements.dart';
import '../../../../pipeline/pipeline.dart';
import '../../../../splits/models/settlement_split.dart';

import '../../financial_posting/financial_posting_result.dart';
import '../../settle_consultation/settle_consultation_context.dart';
import '../../settle_consultation/settle_consultation_result.dart';

import '../finalize_consultation_settlement_result.dart';

/// Mutable state shared by all steps of the final settlement pipeline.
///
/// Every intermediate value is explicitly typed so that each pipeline step
/// communicates through a clear and compile-time-safe contract.
final class FinalizeConsultationSettlementContext
    extends FinancialPipelineContext {
  FinalizeConsultationSettlementContext({required this.settlementContext});

  /// Initial business input supplied to the finalization workflow.
  final SettleConsultationContext settlementContext;

  /// Settlement previously persisted for the same business operation.
  ///
  /// This value is populated before any new financial posting is attempted.
  /// It will later support idempotence, retries and concurrency protection.
  ConsultationSettlement? existingSettlement;

  /// Decision produced after evaluating the persisted settlement.
  ///
  /// Later steps use this value without inspecting SettlementStatus directly.
  SettlementIdempotencyDecision? idempotencyDecision;

  /// Result produced by the consultation fee-settlement workflow.
  SettleConsultationResult? settlementResult;

  /// Financial distribution calculated from the fee quote.
  SettlementSplit? split;

  /// Aggregate built or transitioned during the current execution.
  ConsultationSettlement? settlement;

  /// Result produced after the settlement is posted to the Ledger.
  FinancialPostingResult? postingResult;

  /// Public result returned by the finalization workflow.
  FinalizeConsultationSettlementResult? result;

  /// Returns true when this operation already has a persisted settlement.
  bool get hasExistingSettlement => existingSettlement != null;

  /// Stable settlement identifier derived from the operation identifier.
  SettlementId get settlementId {
    return SettlementId(settlementContext.operationId);
  }

  SettlementIdempotencyDecision get requiredIdempotencyDecision {
    final decision = idempotencyDecision;

    if (decision == null) {
      throw StateError(
        'Settlement idempotency decision has not been evaluated.',
      );
    }

    return decision;
  }
}
