import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/orchestrator/financial_orchestrator.dart';
import 'package:mentora/core/financial/fees/engine/fee_engine.dart';
import 'package:mentora/core/financial/fees/policies/consultation_fee_policy.dart';
import 'package:mentora/core/financial/fees/policies/fee_policy_registry.dart';
import 'package:mentora/core/financial/orchestrator/registry/financial_workflow_registry.dart';

void main() {
  group('FinancialOrchestrator', () {
    late FeeEngine feeEngine;
    late FinancialWorkflowRegistry workflowRegistry;
    late FinancialOrchestrator orchestrator;

    setUp(() {
      final registry = FeePolicyRegistry();

      registry.register(const ConsultationFeePolicy());

      feeEngine = FeeEngine(registry: registry);

      workflowRegistry = FinancialWorkflowRegistry();

      orchestrator = FinancialOrchestrator(
        feeEngine: feeEngine,
        workflowRegistry: workflowRegistry,
      );
    });

    test('should calculate consultation fee quote', () async {
      final quote = await orchestrator.calculateConsultationFees(
        grossAmountMinor: 10000,
        currency: 'XOF',
      );

      expect(quote.platformFeeMinor, 1500);

      expect(quote.vatMinor, 270);

      expect(quote.providerFeeMinor, 100);

      expect(quote.expertNetMinor, 8130);

      expect(quote.isBalanced, isTrue);
    });

    test('should preserve gross amount', () async {
      final quote = await orchestrator.calculateConsultationFees(
        grossAmountMinor: 250000,
        currency: 'EUR',
      );

      expect(quote.grossAmountMinor, 250000);
    });

    test('should normalize currency', () async {
      final quote = await orchestrator.calculateConsultationFees(
        grossAmountMinor: 10000,
        currency: ' xof ',
      );

      expect(quote.currency, 'XOF');
    });

    test('should reject invalid amount', () {
      expect(
        () => orchestrator.calculateConsultationFees(
          grossAmountMinor: 0,
          currency: 'USD',
        ),
        throwsArgumentError,
      );
    });

    test('should remain deterministic', () async {
      final first = await orchestrator.calculateConsultationFees(
        grossAmountMinor: 50000,
        currency: 'USD',
      );

      final second = await orchestrator.calculateConsultationFees(
        grossAmountMinor: 50000,
        currency: 'USD',
      );

      expect(first.expertNetMinor, second.expertNetMinor);

      expect(first.platformFeeMinor, second.platformFeeMinor);

      expect(first.providerFeeMinor, second.providerFeeMinor);

      expect(first.vatMinor, second.vatMinor);
    });
  });
}
