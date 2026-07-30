import '../../../../pipeline/pipeline.dart';

import '../pipeline/finalize_consultation_settlement_context.dart';

final class FinancialConsistencyValidationStep
    implements FinancialPipelineStep<FinalizeConsultationSettlementContext> {
  const FinancialConsistencyValidationStep();

  @override
  String get id => 'financial-consistency';

  @override
  Future<void> execute(FinalizeConsultationSettlementContext context) async {
    final settlement = context.settlementResult!;

    final input = context.settlementContext;

    final currency = input.currency.trim().toUpperCase();

    if (!settlement.feeQuote.isBalanced) {
      throw StateError('Fee quote is not balanced.');
    }

    if (settlement.feeQuote.grossAmountMinor != input.grossAmountMinor) {
      throw StateError('Gross amount mismatch.');
    }

    if (settlement.feeQuote.currency != currency) {
      throw StateError('Currency mismatch.');
    }
  }
}
