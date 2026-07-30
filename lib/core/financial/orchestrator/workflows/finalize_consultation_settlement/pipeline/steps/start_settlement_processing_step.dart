import '../../../../../domain/settlement/'
    'settlement_repository.dart';

import '../../../../../events/settlement/'
    'settlement_event_publisher.dart';

import '../../../../../pipeline/'
    'financial_pipeline_step.dart';

import '../finalize_consultation_settlement_context.dart';

final class StartSettlementProcessingStep
    implements FinancialPipelineStep<FinalizeConsultationSettlementContext> {
  const StartSettlementProcessingStep({
    required SettlementRepository repository,
    required SettlementEventPublisher eventPublisher,
  }) : _repository = repository,
       _eventPublisher = eventPublisher;

  final SettlementRepository _repository;
  final SettlementEventPublisher _eventPublisher;

  @override
  String get id => 'start-settlement-processing';

  @override
  Future<void> execute(FinalizeConsultationSettlementContext context) async {
    final settlement = context.settlement;

    if (settlement == null) {
      throw StateError('No settlement available to start processing.');
    }

    final processingSettlement = settlement.markProcessing();

    final expectedVersion = context.existingSettlement == null
        ? null
        : settlement.version;

    await _repository.save(
      processingSettlement,
      expectedVersion: expectedVersion,
    );

    await _eventPublisher.publish(processingSettlement.pullDomainEvents());

    context.settlement = processingSettlement;
  }
}
