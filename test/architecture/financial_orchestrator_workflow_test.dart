import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/fees/engine/fee_engine.dart';
import 'package:mentora/core/financial/fees/policies/consultation_fee_policy.dart';
import 'package:mentora/core/financial/fees/policies/fee_policy_registry.dart';
import 'package:mentora/core/financial/orchestrator/financial_orchestrator.dart';
import 'package:mentora/core/financial/orchestrator/registry/financial_workflow_registry.dart';
import 'package:mentora/core/financial/orchestrator/workflows/financial_workflow.dart';

void main() {
  group('FinancialOrchestrator workflow integration', () {
    late FeePolicyRegistry feePolicyRegistry;
    late FeeEngine feeEngine;
    late FinancialWorkflowRegistry workflowRegistry;
    late FinancialOrchestrator orchestrator;

    setUp(() {
      feePolicyRegistry = FeePolicyRegistry();

      feePolicyRegistry.register(const ConsultationFeePolicy());

      feeEngine = FeeEngine(registry: feePolicyRegistry);

      workflowRegistry = FinancialWorkflowRegistry();

      orchestrator = FinancialOrchestrator(
        feeEngine: feeEngine,
        workflowRegistry: workflowRegistry,
      );
    });

    test('should execute a workflow resolved through the registry', () async {
      final workflow = _TestSettlementWorkflow();

      workflowRegistry.register<_TestSettlementContext, _TestSettlementResult>(
        workflow,
      );

      final result = await orchestrator
          .executeWorkflow<_TestSettlementContext, _TestSettlementResult>(
            key: 'settle.consultation',
            context: const _TestSettlementContext(
              consultationId: 'consultation_001',
              amountMinor: 10000,
              currency: 'XOF',
            ),
          );

      expect(result.success, isTrue);
      expect(result.consultationId, 'consultation_001');

      expect(workflow.executionCount, 1);

      expect(workflow.lastContext?.consultationId, 'consultation_001');

      expect(workflow.lastContext?.amountMinor, 10000);
    });

    test('should normalize the workflow key through the registry', () async {
      final workflow = _TestSettlementWorkflow();

      workflowRegistry.register<_TestSettlementContext, _TestSettlementResult>(
        workflow,
      );

      final result = await orchestrator
          .executeWorkflow<_TestSettlementContext, _TestSettlementResult>(
            key: '  SETTLE.CONSULTATION  ',
            context: const _TestSettlementContext(
              consultationId: 'consultation_002',
              amountMinor: 25000,
              currency: 'USD',
            ),
          );

      expect(result.success, isTrue);
      expect(result.consultationId, 'consultation_002');
      expect(workflow.executionCount, 1);
    });

    test('should reject an unknown financial workflow', () async {
      expect(
        () => orchestrator
            .executeWorkflow<_TestSettlementContext, _TestSettlementResult>(
              key: 'unknown.workflow',
              context: const _TestSettlementContext(
                consultationId: 'consultation_003',
                amountMinor: 10000,
                currency: 'XOF',
              ),
            ),
        throwsStateError,
      );
    });

    test('should reject incompatible workflow generic types', () async {
      final workflow = _TestSettlementWorkflow();

      workflowRegistry.register<_TestSettlementContext, _TestSettlementResult>(
        workflow,
      );

      expect(
        () => orchestrator.executeWorkflow<_WrongContext, String>(
          key: 'settle.consultation',
          context: const _WrongContext(id: 'wrong_context'),
        ),
        throwsStateError,
      );
    });

    test(
      'should keep calculateConsultationFees working during migration',
      () async {
        final quote = await orchestrator.calculateConsultationFees(
          grossAmountMinor: 10000,
          currency: 'xof',
        );

        expect(quote.grossAmountMinor, 10000);
        expect(quote.currency, 'XOF');

        expect(quote.platformFeeMinor, 1500);
        expect(quote.vatMinor, 270);
        expect(quote.providerFeeMinor, 100);
        expect(quote.expertNetMinor, 8130);

        expect(quote.isBalanced, isTrue);
        expect(quote.breakdown.totalMinor, quote.grossAmountMinor);
      },
    );

    test('should allow legacy fee API and workflow API to coexist', () async {
      final workflow = _TestSettlementWorkflow();

      workflowRegistry.register<_TestSettlementContext, _TestSettlementResult>(
        workflow,
      );

      final quote = await orchestrator.calculateConsultationFees(
        grossAmountMinor: 50000,
        currency: 'USD',
      );

      final workflowResult = await orchestrator
          .executeWorkflow<_TestSettlementContext, _TestSettlementResult>(
            key: 'settle.consultation',
            context: const _TestSettlementContext(
              consultationId: 'consultation_004',
              amountMinor: 50000,
              currency: 'USD',
            ),
          );

      expect(quote.isBalanced, isTrue);
      expect(quote.grossAmountMinor, 50000);

      expect(workflowResult.success, isTrue);
      expect(workflow.executionCount, 1);
    });
  });
}

class _TestSettlementContext {
  final String consultationId;
  final int amountMinor;
  final String currency;

  const _TestSettlementContext({
    required this.consultationId,
    required this.amountMinor,
    required this.currency,
  });
}

class _TestSettlementResult {
  final bool success;
  final String consultationId;

  const _TestSettlementResult({
    required this.success,
    required this.consultationId,
  });
}

class _WrongContext {
  final String id;

  const _WrongContext({required this.id});
}

class _TestSettlementWorkflow
    implements
        FinancialWorkflow<_TestSettlementContext, _TestSettlementResult> {
  int executionCount = 0;

  _TestSettlementContext? lastContext;

  @override
  String get key => 'settle.consultation';

  @override
  Future<_TestSettlementResult> execute(_TestSettlementContext context) async {
    executionCount++;
    lastContext = context;

    return _TestSettlementResult(
      success: true,
      consultationId: context.consultationId,
    );
  }
}
