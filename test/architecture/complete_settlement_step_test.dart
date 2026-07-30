import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/infrastructure/'
    'settlement/in_memory_settlement_repository.dart';

import 'package:mentora/core/financial/domain/settlement/'
    'settlements.dart';

import 'package:mentora/core/financial/events/settlement/'
    'settlement_event_dispatcher.dart';

import 'package:mentora/core/financial/events/settlement/'
    'settlement_event_publisher.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/pipeline/'
    'finalize_consultation_settlement_context.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/steps/'
    'build_consultation_settlement_step.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/pipeline/steps/'
    'complete_settlement_step.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/pipeline/steps/'
    'start_settlement_processing_step.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'settle_consultation/settle_consultation_context.dart';

import 'package:mentora/core/financial/orchestrator/workflows/financial_posting/financial_posting_result.dart';

import 'package:mentora/core/financial/splits/models/'
    'settlement_split.dart';

import 'package:mentora/core/financial/splits/models/'
    'settlement_split_component.dart';

import 'package:mentora/core/financial/splits/models/'
    'split_destination.dart';

void main() {
  group('CompleteSettlementStep', () {
    Future<FinalizeConsultationSettlementContext> createProcessingContext({
      required SettlementRepository repository,
      required SettlementEventPublisher publisher,
    }) async {
      final context =
          FinalizeConsultationSettlementContext(
              settlementContext: SettleConsultationContext(
                operationId: 'settlement_001',
                consultationId: 'consultation_001',
                paymentId: 'payment_001',
                escrowId: 'escrow_001',
                clientId: 'client_001',
                expertId: 'expert_001',
                grossAmountMinor: 10000,
                currency: 'XOF',
                occurredAt: DateTime.utc(2026, 7, 18),
              ),
            )
            ..idempotencyDecision =
                SettlementIdempotencyDecision.continueProcessing
            ..split = createValidSplit();

      const buildStep = BuildConsultationSettlementStep();

      await buildStep.execute(context);

      final startStep = StartSettlementProcessingStep(
        repository: repository,
        eventPublisher: publisher,
      );

      await startStep.execute(context);

      return context;
    }

    test('persists completed settlement before publishing its event', () async {
      final repository = InMemorySettlementRepository();

      final dispatcher = _RecordingDispatcher();

      final publisher = SettlementEventPublisher(dispatcher: dispatcher);

      final context = await createProcessingContext(
        repository: repository,
        publisher: publisher,
      );

      dispatcher.dispatchedEvents.clear();

      final processingSettlement = context.settlement!;

      context.postingResult = FinancialPostingResult(
        success: true,
        operationId: 'settlement_001',
        consultationId: 'consultation_001',
        ledgerTransactionIds: const <String>['ledger_tx_001'],
        postedAt: DateTime.utc(2026, 7, 18, 12),
      );

      final step = CompleteSettlementStep(
        repository: repository,
        eventPublisher: publisher,
      );

      await step.execute(context);

      final completedSettlement = context.settlement!;

      expect(completedSettlement.status, SettlementStatus.completed);

      expect(completedSettlement.version, processingSettlement.version + 1);

      final persistedSettlement = await repository.findById(
        completedSettlement.id,
      );

      expect(persistedSettlement, isNotNull);

      expect(persistedSettlement!.status, SettlementStatus.completed);

      expect(dispatcher.dispatchedEvents, hasLength(1));

      expect(dispatcher.dispatchedEvents.single, isA<SettlementCompleted>());

      final event = dispatcher.dispatchedEvents.single as SettlementCompleted;

      expect(event.settlementId, completedSettlement.id);
    });

    test('does not publish or update context when persistence fails', () async {
      final initialRepository = InMemorySettlementRepository();

      final initialDispatcher = _RecordingDispatcher();

      final initialPublisher = SettlementEventPublisher(
        dispatcher: initialDispatcher,
      );

      final context = await createProcessingContext(
        repository: initialRepository,
        publisher: initialPublisher,
      );

      final processingSettlement = context.settlement!;

      context.postingResult = FinancialPostingResult(
        success: true,
        operationId: 'settlement_001',
        consultationId: 'consultation_001',
        ledgerTransactionIds: const <String>['ledger_tx_001'],
        postedAt: DateTime.utc(2026, 7, 18, 12),
      );

      final failingRepository = _FailingSettlementRepository();

      final dispatcher = _RecordingDispatcher();

      final publisher = SettlementEventPublisher(dispatcher: dispatcher);

      final step = CompleteSettlementStep(
        repository: failingRepository,
        eventPublisher: publisher,
      );

      expect(
        () => step.execute(context),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Simulated settlement persistence failure.',
          ),
        ),
      );

      expect(context.settlement, same(processingSettlement));

      expect(context.settlement!.status, SettlementStatus.processing);

      expect(dispatcher.dispatchedEvents, isEmpty);
    });
  });
}

SettlementSplit createValidSplit() {
  return const SettlementSplit(
    grossAmountMinor: 10000,
    currency: 'XOF',
    components: <SettlementSplitComponent>[
      SettlementSplitComponent(
        destination: SplitDestination.expertWallet,
        amountMinor: 7000,
        code: 'EXPERT_REVENUE',
        label: 'Expert revenue',
      ),
      SettlementSplitComponent(
        destination: SplitDestination.platformRevenue,
        amountMinor: 1500,
        code: 'PLATFORM_REVENUE',
        label: 'Platform revenue',
      ),
      SettlementSplitComponent(
        destination: SplitDestination.taxPayable,
        amountMinor: 1000,
        code: 'TAX_PAYABLE',
        label: 'Tax payable',
      ),
      SettlementSplitComponent(
        destination: SplitDestination.paymentProviderFee,
        amountMinor: 500,
        code: 'PAYMENT_PROVIDER_FEE',
        label: 'Payment provider fee',
      ),
    ],
  );
}

final class _RecordingDispatcher implements SettlementEventDispatcher {
  final List<SettlementDomainEvent> dispatchedEvents =
      <SettlementDomainEvent>[];

  @override
  Future<void> dispatch(SettlementDomainEvent event) async {
    dispatchedEvents.add(event);
  }

  @override
  Future<void> dispatchAll(Iterable<SettlementDomainEvent> events) async {
    for (final event in events) {
      await dispatch(event);
    }
  }
}

final class _FailingSettlementRepository implements SettlementRepository {
  @override
  Future<void> save(ConsultationSettlement settlement, {int? expectedVersion}) {
    throw StateError('Simulated settlement persistence failure.');
  }

  @override
  Future<ConsultationSettlement?> findById(SettlementId id) async {
    return null;
  }

  @override
  Future<bool> exists(SettlementId id) async {
    return false;
  }

  @override
  Future<void> delete(SettlementId id) async {}
}
