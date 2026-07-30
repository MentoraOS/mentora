import '../../../../domain/settlement/settlements.dart';
import '../../../../pipeline/pipeline.dart';

import '../pipeline/finalize_consultation_settlement_context.dart';

/// Loads an already persisted settlement for the current operation.
///
/// This step must execute before any state transition or Ledger posting.
/// It is the foundation of idempotence, retries and concurrency control.
final class LoadExistingSettlementStep
    implements FinancialPipelineStep<FinalizeConsultationSettlementContext> {
  const LoadExistingSettlementStep({required this.repository});

  final SettlementRepository repository;

  @override
  String get id => 'load-existing-settlement';

  @override
  Future<void> execute(FinalizeConsultationSettlementContext context) async {
    final existingSettlement = await repository.findById(context.settlementId);

    context.existingSettlement = existingSettlement;
  }
}
