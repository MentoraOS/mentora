import '../../../../pipeline/pipeline.dart';
import '../../../../splits/engine/split_engine.dart';

import '../pipeline/finalize_consultation_settlement_context.dart';

/// Builds the settlement split from the fee quote produced by the
/// consultation settlement step.
///
/// This step also validates the consistency of the generated split.
final class SplitCalculationStep
    implements FinancialPipelineStep<FinalizeConsultationSettlementContext> {
  const SplitCalculationStep({required SplitEngine splitEngine})
    : _splitEngine = splitEngine;

  final SplitEngine _splitEngine;

  @override
  String get id => 'calculate-settlement-split';

  @override
  Future<void> execute(FinalizeConsultationSettlementContext context) async {
    final settlementResult = context.settlementResult;

    if (settlementResult == null) {
      throw StateError(
        'Cannot calculate the settlement split before '
        'the consultation settlement has completed.',
      );
    }

    final split = _splitEngine.build(feeQuote: settlementResult.feeQuote);

    final input = context.settlementContext;
    final normalizedCurrency = input.currency.trim().toUpperCase();

    if (!split.isBalanced) {
      throw StateError('Cannot finalize an unbalanced settlement split.');
    }

    if (split.grossAmountMinor != input.grossAmountMinor) {
      throw StateError(
        'Settlement split gross amount does not match '
        'the settlement context.',
      );
    }

    if (split.currency != normalizedCurrency) {
      throw StateError(
        'Settlement split currency does not match '
        'the settlement context.',
      );
    }

    context.split = split;
  }
}
