import '../../../../pipeline/pipeline.dart';

import '../pipeline/finalize_consultation_settlement_context.dart';

/// Validates that the posting workflow produced a successful ledger result.
final class PostingValidationStep
    implements FinancialPipelineStep<FinalizeConsultationSettlementContext> {
  const PostingValidationStep();

  @override
  String get id => 'validate-settlement-posting';

  @override
  Future<void> execute(FinalizeConsultationSettlementContext context) async {
    final split = context.split;
    final postingResult = context.postingResult;

    if (split == null) {
      throw StateError(
        'Settlement split is missing during posting validation.',
      );
    }

    if (postingResult == null) {
      throw StateError('Consultation settlement posting result is missing.');
    }

    if (!postingResult.success) {
      throw StateError('Consultation settlement posting was not successful.');
    }

    if (postingResult.ledgerTransactionIds.isEmpty) {
      throw StateError(
        'Consultation settlement generated no ledger transactions.',
      );
    }

    if (postingResult.operationId.trim().isEmpty) {
      throw StateError(
        'Consultation settlement posting operationId is missing.',
      );
    }

    if (postingResult.consultationId.trim().isEmpty) {
      throw StateError(
        'Consultation settlement posting consultationId is missing.',
      );
    }
  }
}
