import '../../../../pipeline/pipeline.dart';

import '../finalize_consultation_settlement_result.dart';
import '../pipeline/finalize_consultation_settlement_context.dart';

/// Builds the final public result returned by
/// FinalizeConsultationSettlementWorkflow.
final class BuildFinalizeResultStep
    implements FinancialPipelineStep<FinalizeConsultationSettlementContext> {
  const BuildFinalizeResultStep();

  @override
  String get id => 'build-finalize-settlement-result';

  @override
  Future<void> execute(FinalizeConsultationSettlementContext context) async {
    final input = context.settlementContext;
    final settlementResult = context.settlementResult;
    final split = context.split;
    final postingResult = context.postingResult;

    if (settlementResult == null) {
      throw StateError(
        'Cannot build the final result without '
        'a consultation settlement result.',
      );
    }

    if (split == null) {
      throw StateError(
        'Cannot build the final result without '
        'a settlement split.',
      );
    }

    if (postingResult == null) {
      throw StateError(
        'Cannot build the final result without '
        'a posting result.',
      );
    }

    context.result = FinalizeConsultationSettlementResult(
      success: true,
      operationId: settlementResult.operationId,
      consultationId: settlementResult.consultationId,
      feeQuote: settlementResult.feeQuote,
      split: split,
      postingResult: postingResult,
      finalizedAt: input.occurredAt.toUtc(),
    );
  }
}
