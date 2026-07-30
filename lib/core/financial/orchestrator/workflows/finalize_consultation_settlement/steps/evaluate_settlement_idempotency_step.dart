import '../../../../domain/settlement/'
    'settlement_idempotency_policy.dart';
import '../../../../pipeline/pipeline.dart';

import '../pipeline/finalize_consultation_settlement_context.dart';

/// Evaluates how the pipeline must handle an already persisted settlement.
///
/// This step translates the persisted aggregate state into a stable business
/// decision. Downstream steps must consume the decision instead of inspecting
/// SettlementStatus directly.
final class EvaluateSettlementIdempotencyStep
    implements FinancialPipelineStep<FinalizeConsultationSettlementContext> {
  const EvaluateSettlementIdempotencyStep({
    this.policy = const SettlementIdempotencyPolicy(),
  });

  final SettlementIdempotencyPolicy policy;

  @override
  String get id => 'evaluate-settlement-idempotency';

  @override
  Future<void> execute(FinalizeConsultationSettlementContext context) async {
    context.idempotencyDecision = policy.evaluate(context.existingSettlement);
  }
}
