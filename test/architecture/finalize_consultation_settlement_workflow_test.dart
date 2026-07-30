import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/fees/engine/fee_engine.dart';
import 'package:mentora/core/financial/fees/policies/fee_policy_registry.dart';

import 'package:mentora/core/financial/orchestrator/workflows/financial_posting/financial_posting_workflow.dart';
import 'package:mentora/core/financial/orchestrator/workflows/financial_posting/settlement_posting_port.dart';
import 'package:mentora/core/financial/orchestrator/workflows/financial_posting/settlement_posting_receipt.dart';

import 'package:mentora/core/financial/orchestrator/workflows/finalize_consultation_settlement/finalize_consultation_settlement_result.dart';
import 'package:mentora/core/financial/orchestrator/workflows/finalize_consultation_settlement/finalize_consultation_settlement_workflow.dart';

import 'package:mentora/core/financial/orchestrator/workflows/settle_consultation/settle_consultation_context.dart';
import 'package:mentora/core/financial/orchestrator/workflows/settle_consultation/settle_consultation_workflow.dart';

import 'package:mentora/core/financial/splits/engine/split_engine.dart';

import 'package:mentora/core/financial/splits/models/split_destination.dart';
import 'package:mentora/core/financial/pipeline/'
    'default_financial_pipeline_engine.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/pipeline/'
    'finalize_consultation_settlement_pipeline.dart';

import 'package:mentora/core/financial/fees/policies/consultation_fee_policy.dart';

import 'package:mentora/core/financial/runtime/engine/'
    'default_financial_runtime.dart';
import 'package:mentora/core/financial/orchestrator/workflows/financial_posting/models/settlement_posting_instruction.dart';
import 'package:mentora/core/financial/domain/infrastructure/settlement/in_memory_settlement_repository.dart';
import 'package:mentora/core/financial/domain/settlement/settlement_domain_event.dart';
import 'package:mentora/core/financial/events/settlement/in_memory_settlement_event_dispatcher.dart';
import 'package:mentora/core/financial/events/settlement/settlement_event_handler.dart';
import 'package:mentora/core/financial/events/settlement/settlement_event_publisher.dart';
import 'package:mentora/core/financial/orchestrator/workflows/finalize_consultation_settlement/pipeline/settlement_failure_handler.dart';

void main() {
  group('FinalizeConsultationSettlementWorkflow', () {
    late FeePolicyRegistry feePolicyRegistry;
    late FeeEngine feeEngine;

    late SettleConsultationWorkflow settlementWorkflow;
    late SplitEngine splitEngine;

    late _FakeSettlementPostingPort postingPort;
    late FinancialPostingWorkflow financialPostingWorkflow;

    late FinalizeConsultationSettlementWorkflow workflow;
    late FinalizeConsultationSettlementPipeline pipeline;

    setUp(() {
      feePolicyRegistry = FeePolicyRegistry();

      feePolicyRegistry.register(const ConsultationFeePolicy());

      feeEngine = FeeEngine(registry: feePolicyRegistry);

      settlementWorkflow = SettleConsultationWorkflow(feeEngine: feeEngine);

      final settlementRepository = InMemorySettlementRepository();

      splitEngine = const SplitEngine();

      postingPort = _FakeSettlementPostingPort();

      financialPostingWorkflow = FinancialPostingWorkflow(
        postingPort: postingPort,
      );

      pipeline = FinalizeConsultationSettlementPipeline(
        settlementWorkflow: settlementWorkflow,
        splitEngine: splitEngine,
        financialPostingWorkflow: financialPostingWorkflow,
        settlementRepository: settlementRepository,
        eventPublisher: SettlementEventPublisher(
          dispatcher: InMemorySettlementEventDispatcher(
            handlers: const <SettlementEventHandler<SettlementDomainEvent>>[],
          ),
        ),
      );

      final financialRuntime = DefaultFinancialRuntime(
        pipelineEngine: DefaultFinancialPipelineEngine(),
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
    });

    test('should expose the finalize consultation settlement key', () {
      expect(workflow.key, 'finalize.consultation.settlement');
    });

    test(
      'should execute the complete consultation settlement pipeline',
      () async {
        final FinalizeConsultationSettlementResult result = await workflow
            .execute(_buildContext());

        expect(result.success, isTrue);

        expect(result.operationId, 'settlement_001');
        expect(result.consultationId, 'consultation_001');

        expect(result.feeQuote.grossAmountMinor, 10000);

        expect(result.feeQuote.currency, 'XOF');
        expect(result.feeQuote.platformFeeMinor, 1500);
        expect(result.feeQuote.vatMinor, 270);
        expect(result.feeQuote.providerFeeMinor, 100);
        expect(result.feeQuote.expertNetMinor, 8130);

        expect(result.split.grossAmountMinor, 10000);
        expect(result.split.totalMinor, 10000);
        expect(result.split.isBalanced, isTrue);

        expect(result.isFinanciallyBalanced, isTrue);

        expect(result.ledgerTransactionIds.length, 4);
        expect(postingPort.callCount, 1);

        expect(result.finalizedAt, DateTime.utc(2026, 7, 12, 10));
      },
    );

    test('should preserve every financial allocation', () async {
      final result = await workflow.execute(_buildContext());

      expect(result.split.amountFor(SplitDestination.expertWallet), 8130);

      expect(result.split.amountFor(SplitDestination.platformRevenue), 1500);

      expect(result.split.amountFor(SplitDestination.taxPayable), 270);

      expect(result.split.amountFor(SplitDestination.paymentProviderFee), 100);
    });

    test(
      'should forward settlement identity and metadata to posting',
      () async {
        await workflow.execute(_buildContext());
        final instruction = postingPort.lastInstruction;

        expect(instruction, isNotNull);
        expect(instruction!.operationId, 'settlement_001');
        expect(instruction.consultationId, 'consultation_001');
        expect(instruction.escrowId, 'escrow_001');
        expect(instruction.clientId, 'client_001');
        expect(instruction.expertId, 'expert_001');

        expect(
          instruction.metadata['source'],
          'finalize_consultation_settlement_workflow_test',
        );

        expect(instruction.metadata['paymentId'], 'payment_001');
      },
    );

    test('should normalize settlement currency', () async {
      final result = await workflow.execute(_buildContext(currency: ' xof '));

      expect(result.feeQuote.currency, 'XOF');
      expect(result.split.currency, 'XOF');

      expect(postingPort.lastInstruction?.currency.code, 'XOF');
    });

    test('should reject an invalid context before posting', () async {
      await expectLater(
        workflow.execute(_buildContext(consultationId: ' ')),
        throwsArgumentError,
      );

      expect(postingPort.callCount, 0);
    });

    test('should reject a non-positive amount before posting', () async {
      await expectLater(
        workflow.execute(_buildContext(grossAmountMinor: 0)),
        throwsArgumentError,
      );

      expect(postingPort.callCount, 0);
    });

    test('should propagate posting failures', () async {
      postingPort.shouldFail = true;

      await expectLater(workflow.execute(_buildContext()), throwsStateError);

      expect(postingPort.callCount, 1);
    });

    test('should prevent duplicate execution for the same context', () async {
      final context = _buildContext(grossAmountMinor: 50000, currency: 'USD');

      final first = await workflow.execute(context);

      expect(first.success, isTrue);

      expect(first.feeQuote.grossAmountMinor, 50000);
      expect(first.split.totalMinor, 50000);

      await expectLater(
        workflow.execute(context),
        throwsA(
          isA<StateError>().having(
            (e) => e.toString(),
            'message',
            contains('already been completed'),
          ),
        ),
      );

      // Le posting ne doit avoir eu lieu qu'une seule fois.
      expect(postingPort.callCount, 1);
    });
  });
}

SettleConsultationContext _buildContext({
  String operationId = 'settlement_001',
  String consultationId = 'consultation_001',
  String paymentId = 'payment_001',
  String escrowId = 'escrow_001',
  String clientId = 'client_001',
  String expertId = 'expert_001',
  int grossAmountMinor = 10000,
  String currency = 'XOF',
}) {
  return SettleConsultationContext(
    operationId: operationId,
    consultationId: consultationId,
    paymentId: paymentId,
    escrowId: escrowId,
    clientId: clientId,
    expertId: expertId,
    grossAmountMinor: grossAmountMinor,
    currency: currency,
    occurredAt: DateTime.utc(2026, 7, 12, 10),
    metadata: const {
      'source': 'finalize_consultation_settlement_workflow_test',
      'environment': 'test',
    },
  );
}

class _FakeSettlementPostingPort implements SettlementPostingPort {
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
      throw StateError('Simulated final settlement posting failure');
    }

    return SettlementPostingReceipt(
      operationId: instruction.operationId,
      ledgerTransactionIds: instruction.lines
          .map(
            (line) => '${instruction.operationId}_${line.code.toLowerCase()}',
          )
          .toList(growable: false),
    );
  }
}
