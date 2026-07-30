import '../../../../domain/settlement/'
    'settlement_idempotency_decision.dart';
import '../../../../pipeline/pipeline.dart';

import '../pipeline/finalize_consultation_settlement_context.dart';

/// Applies the idempotency decision produced for the persisted settlement.
///
/// This first version protects the pipeline from terminal settlement states.
/// Resume, retry and early-success behavior will be enriched incrementally.
final class ApplySettlementIdempotencyDecisionStep
    implements FinancialPipelineStep<FinalizeConsultationSettlementContext> {
  const ApplySettlementIdempotencyDecisionStep();

  @override
  String get id => 'apply-settlement-idempotency-decision';

  @override
  Future<void> execute(FinalizeConsultationSettlementContext context) async {
    final decision = context.requiredIdempotencyDecision;

    switch (decision) {
      case SettlementIdempotencyDecision.continueProcessing:
      case SettlementIdempotencyDecision.resume:
      case SettlementIdempotencyDecision.retry:
        return;

      case SettlementIdempotencyDecision.alreadyCompleted:
        throw StateError(
          'Settlement "${context.settlementId}" '
          'has already been completed. '
          'Duplicate financial posting is not allowed.',
        );

      case SettlementIdempotencyDecision.reject:
        final status = context.existingSettlement?.status.name ?? 'unknown';

        throw StateError(
          'Settlement "${context.settlementId}" '
          'cannot continue from status "$status".',
        );
    }
  }
}
