import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/infrastructure/'
    'settlement/in_memory_settlement_repository.dart';

import 'package:mentora/core/financial/domain/settlement/'
    'settlements.dart';

import 'package:mentora/core/financial/domain/settlement/'
    'settlement_domain_event.dart';

import 'package:mentora/core/financial/events/settlement/'
    'in_memory_settlement_event_dispatcher.dart';

import 'package:mentora/core/financial/events/settlement/'
    'settlement_event_handler.dart';

import 'package:mentora/core/financial/events/settlement/'
    'settlement_event_publisher.dart';

import 'package:mentora/core/financial/fees/engine/'
    'fee_engine.dart';

import 'package:mentora/core/financial/fees/policies/'
    'consultation_fee_policy.dart';

import 'package:mentora/core/financial/fees/policies/'
    'fee_policy_registry.dart';

import 'package:mentora/core/financial/orchestrator/'
    'financial_orchestrator.dart';

import 'package:mentora/core/financial/orchestrator/registry/'
    'financial_workflow_registry.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/financial_posting_workflow.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/models/'
    'settlement_posting_instruction.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/settlement_posting_port.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/settlement_posting_receipt.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/'
    'finalize_consultation_settlement_result.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/'
    'finalize_consultation_settlement_workflow.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/pipeline/'
    'finalize_consultation_settlement_pipeline.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/pipeline/'
    'settlement_failure_handler.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'settle_consultation/settle_consultation_context.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'settle_consultation/settle_consultation_workflow.dart';

import 'package:mentora/core/financial/pipeline/'
    'default_financial_pipeline_engine.dart';

import 'package:mentora/core/financial/runtime/engine/'
    'default_financial_runtime.dart';

import 'package:mentora/core/financial/splits/engine/'
    'split_engine.dart';

import 'package:mentora/core/financial/splits/models/'
    'split_destination.dart';

void main() {
  group('FinancialOrchestrator + '
      'FinalizeConsultationSettlementWorkflow V2', () {
    late FeeEngine feeEngine;

    late FinancialOrchestrator orchestrator;
    late FinalizeConsultationSettlementWorkflow workflow;

    late _FakeSettlementPostingPort postingPort;
    late InMemorySettlementRepository settlementRepository;

    setUp(() {
      final feePolicyRegistry = FeePolicyRegistry();

      feePolicyRegistry.register(const ConsultationFeePolicy());

      feeEngine = FeeEngine(registry: feePolicyRegistry);

      final settlementWorkflow = SettleConsultationWorkflow(
        feeEngine: feeEngine,
      );

      postingPort = _FakeSettlementPostingPort();

      final postingWorkflow = FinancialPostingWorkflow(
        postingPort: postingPort,
      );

      settlementRepository = InMemorySettlementRepository();

      final pipelineEngine = DefaultFinancialPipelineEngine();

      final financialRuntime = DefaultFinancialRuntime(
        pipelineEngine: pipelineEngine,
      );

      final pipeline = FinalizeConsultationSettlementPipeline(
        settlementWorkflow: settlementWorkflow,
        splitEngine: const SplitEngine(),
        financialPostingWorkflow: postingWorkflow,
        settlementRepository: settlementRepository,
        eventPublisher: SettlementEventPublisher(
          dispatcher: InMemorySettlementEventDispatcher(
            handlers: const <SettlementEventHandler<SettlementDomainEvent>>[],
          ),
        ),
      );

      final failureHandler = SettlementFailureHandler(
        repository: settlementRepository,
      );

      workflow = FinalizeConsultationSettlementWorkflow(
        financialRuntime: financialRuntime,
        pipeline: pipeline,
        failureHandler: failureHandler,
        executionIdFactory: (context) {
          return 'test-settlement-execution';
        },
        correlationIdFactory: (context) {
          return 'test-settlement-correlation';
        },
      );

      final registry = FinancialWorkflowRegistry();

      registry.register(settlementWorkflow);
      registry.register(postingWorkflow);
      registry.register(workflow);

      orchestrator = FinancialOrchestrator(
        feeEngine: feeEngine,
        workflowRegistry: registry,
      );
    });

    test('should execute the complete settlement lifecycle', () async {
      final result = await _executeWorkflow(orchestrator);

      expect(result.success, isTrue);
      expect(result.operationId, 'settlement_001');
      expect(result.consultationId, 'consultation_001');

      expect(result.feeQuote.grossAmountMinor, 10000);
      expect(result.feeQuote.currency, 'XOF');

      expect(result.split.isBalanced, isTrue);
      expect(result.split.totalMinor, 10000);
      expect(result.isFinanciallyBalanced, isTrue);

      expect(result.ledgerTransactionIds.length, 4);

      expect(postingPort.callCount, 1);

      final persistedSettlement = await settlementRepository.findById(
        SettlementId('settlement_001'),
      );

      expect(persistedSettlement, isNotNull);
      expect(persistedSettlement!.status, SettlementStatus.completed);
      expect(persistedSettlement.isCompleted, isTrue);

      // pending v0
      // processing v1
      // completed v2
      expect(persistedSettlement.version, 2);
    });

    test('should persist failed state when posting fails', () async {
      postingPort.shouldFail = true;

      await expectLater(
        _executeWorkflow(orchestrator),
        throwsA(
          isA<StateError>().having(
            (error) => error.toString(),
            'message',
            contains(
              'Simulated orchestrator '
              'posting failure',
            ),
          ),
        ),
      );

      expect(postingPort.callCount, 1);

      final persistedSettlement = await settlementRepository.findById(
        SettlementId('settlement_001'),
      );

      expect(persistedSettlement, isNotNull);

      expect(persistedSettlement!.status, SettlementStatus.failed);
      expect(persistedSettlement.isFailed, isTrue);

      // pending v0
      // processing v1
      // failed v2
      expect(persistedSettlement.version, 2);
    });

    test('should preserve all settlement allocations', () async {
      final result = await _executeWorkflow(orchestrator);

      expect(result.split.amountFor(SplitDestination.expertWallet), 8130);

      expect(result.split.amountFor(SplitDestination.platformRevenue), 1500);

      expect(result.split.amountFor(SplitDestination.taxPayable), 270);

      expect(result.split.amountFor(SplitDestination.paymentProviderFee), 100);
    });

    test('should resolve a normalized workflow key', () async {
      final result = await orchestrator
          .executeWorkflow<
            SettleConsultationContext,
            FinalizeConsultationSettlementResult
          >(
            key: '  FINALIZE.CONSULTATION.SETTLEMENT  ',
            context: _buildContext(),
          );

      expect(result.success, isTrue);
      expect(postingPort.callCount, 1);

      final persistedSettlement = await settlementRepository.findById(
        SettlementId('settlement_001'),
      );

      expect(persistedSettlement?.status, SettlementStatus.completed);
    });

    test('should reject an unknown workflow', () async {
      await expectLater(
        orchestrator.executeWorkflow<
          SettleConsultationContext,
          FinalizeConsultationSettlementResult
        >(key: 'unknown.workflow', context: _buildContext()),
        throwsStateError,
      );

      expect(postingPort.callCount, 0);

      final persistedSettlement = await settlementRepository.findById(
        SettlementId('settlement_001'),
      );

      expect(persistedSettlement, isNull);
    });

    test('should prevent a completed settlement '
        'from being posted twice', () async {
      final firstResult = await _executeWorkflow(orchestrator);

      expect(firstResult.success, isTrue);
      expect(postingPort.callCount, 1);

      await expectLater(
        _executeWorkflow(orchestrator),
        throwsA(
          isA<StateError>().having(
            (error) => error.toString(),
            'message',
            contains('already been completed'),
          ),
        ),
      );

      // The second execution must not reach
      // the posting port.
      expect(postingPort.callCount, 1);

      final persistedSettlement = await settlementRepository.findById(
        SettlementId('settlement_001'),
      );

      expect(persistedSettlement?.status, SettlementStatus.completed);
      expect(persistedSettlement?.version, 2);
    });
  });
}

Future<FinalizeConsultationSettlementResult> _executeWorkflow(
  FinancialOrchestrator orchestrator,
) {
  return orchestrator.executeWorkflow<
    SettleConsultationContext,
    FinalizeConsultationSettlementResult
  >(
    key: FinalizeConsultationSettlementWorkflow.workflowKey,
    context: _buildContext(),
  );
}

SettleConsultationContext _buildContext() {
  return SettleConsultationContext(
    operationId: 'settlement_001',
    consultationId: 'consultation_001',
    paymentId: 'payment_001',
    escrowId: 'escrow_001',
    clientId: 'client_001',
    expertId: 'expert_001',
    grossAmountMinor: 10000,
    currency: 'XOF',
    occurredAt: DateTime.utc(2026, 7, 13, 10),
    metadata: const <String, dynamic>{
      'source': 'financial_orchestrator_finalize_workflow_test',
    },
  );
}

final class _FakeSettlementPostingPort implements SettlementPostingPort {
  int callCount = 0;
  bool shouldFail = false;

  SettlementPostingInstruction? lastInstruction;

  @override
  Future<SettlementPostingReceipt> postSettlement({
    required SettlementPostingInstruction instruction,
  }) async {
    callCount++;
    lastInstruction = instruction;

    if (shouldFail) {
      throw StateError('Simulated orchestrator posting failure');
    }

    return SettlementPostingReceipt(
      operationId: instruction.operationId,
      ledgerTransactionIds: instruction.lines
          .map(
            (line) =>
                '${instruction.operationId}_'
                '${line.code.toLowerCase()}',
          )
          .toList(growable: false),
    );
  }
}
