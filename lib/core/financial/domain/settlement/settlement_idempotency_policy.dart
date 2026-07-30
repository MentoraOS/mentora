import 'consultation_settlement.dart';
import 'settlement_idempotency_decision.dart';
import 'settlement_status.dart';

/// Centralizes every idempotency decision for settlement processing.
///
/// The pipeline never checks settlement statuses directly.
/// Instead, it delegates the decision to this policy.
final class SettlementIdempotencyPolicy {
  const SettlementIdempotencyPolicy();

  SettlementIdempotencyDecision evaluate(ConsultationSettlement? settlement) {
    if (settlement == null) {
      return SettlementIdempotencyDecision.continueProcessing;
    }

    return switch (settlement.status) {
      SettlementStatus.pending => SettlementIdempotencyDecision.resume,

      SettlementStatus.processing => SettlementIdempotencyDecision.resume,

      SettlementStatus.completed =>
        SettlementIdempotencyDecision.alreadyCompleted,

      SettlementStatus.failed => SettlementIdempotencyDecision.retry,

      SettlementStatus.cancelled => SettlementIdempotencyDecision.reject,

      SettlementStatus.refunded => SettlementIdempotencyDecision.reject,
    };
  }
}
