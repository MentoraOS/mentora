import '../../../../../domain/settlement/'
    'settlement_repository.dart';

import '../../../../../events/settlement/'
    'settlement_event_publisher.dart';

import '../../../../../pipeline/'
    'financial_pipeline_step.dart';

import '../finalize_consultation_settlement_context.dart';

/// Completes and persists a settlement after successful Ledger posting.
///
/// This step must run only after PostingValidationStep has confirmed that
/// the financial posting succeeded and produced Ledger transactions.
final class CompleteSettlementStep
    implements FinancialPipelineStep<FinalizeConsultationSettlementContext> {
  const CompleteSettlementStep({
    required SettlementRepository repository,
    required SettlementEventPublisher eventPublisher,
  }) : _repository = repository,
       _eventPublisher = eventPublisher;

  final SettlementRepository _repository;
  final SettlementEventPublisher _eventPublisher;

  @override
  String get id => 'complete-settlement';

  @override
  Future<void> execute(FinalizeConsultationSettlementContext context) async {
    final settlement = context.settlement;

    if (settlement == null) {
      throw StateError('No settlement is available for completion.');
    }

    final postingResult = context.postingResult;

    if (postingResult == null) {
      throw StateError(
        'Settlement cannot be completed without '
        'a financial posting result.',
      );
    }

    if (!postingResult.success) {
      throw StateError(
        'Settlement cannot be completed because '
        'financial posting was not successful.',
      );
    }

    if (postingResult.ledgerTransactionIds.isEmpty) {
      throw StateError(
        'Settlement cannot be completed without '
        'Ledger transactions.',
      );
    }

    final completedSettlement = settlement.markCompleted();

    await _repository.save(
      completedSettlement,
      expectedVersion: settlement.version,
    );

    await _eventPublisher.publish(completedSettlement.pullDomainEvents());

    context.settlement = completedSettlement;
  }
}
