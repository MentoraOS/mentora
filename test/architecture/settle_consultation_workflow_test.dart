import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/fees/engine/fee_engine.dart';
import 'package:mentora/core/financial/fees/policies/consultation_fee_policy.dart';
import 'package:mentora/core/financial/fees/policies/fee_policy_registry.dart';

import 'package:mentora/core/financial/orchestrator/workflows/settle_consultation/settle_consultation_context.dart';
import 'package:mentora/core/financial/orchestrator/workflows/settle_consultation/settle_consultation_result.dart';
import 'package:mentora/core/financial/orchestrator/workflows/settle_consultation/settle_consultation_workflow.dart';

void main() {
  group('SettleConsultationWorkflow', () {
    late FeePolicyRegistry feePolicyRegistry;
    late FeeEngine feeEngine;
    late SettleConsultationWorkflow workflow;

    setUp(() {
      feePolicyRegistry = FeePolicyRegistry();

      feePolicyRegistry.register(const ConsultationFeePolicy());

      feeEngine = FeeEngine(registry: feePolicyRegistry);

      workflow = SettleConsultationWorkflow(feeEngine: feeEngine);
    });

    test('should expose the settle consultation workflow key', () {
      expect(workflow.key, 'settle.consultation');
    });

    test('should prepare a balanced consultation settlement', () async {
      final context = _buildContext(grossAmountMinor: 10000, currency: 'xof');

      final result = await workflow.execute(context);

      expect(result.success, isTrue);
      expect(result.operationId, 'settlement_001');
      expect(result.consultationId, 'consultation_001');

      expect(result.feeQuote.grossAmountMinor, 10000);
      expect(result.feeQuote.currency, 'XOF');

      expect(result.feeQuote.platformFeeMinor, 1500);
      expect(result.feeQuote.vatMinor, 270);
      expect(result.feeQuote.providerFeeMinor, 100);
      expect(result.feeQuote.expertNetMinor, 8130);

      expect(result.feeQuote.isBalanced, isTrue);
      expect(result.feeQuote.breakdown.totalMinor, 10000);

      expect(result.settledAt, DateTime.utc(2026, 7, 12, 10));
    });

    test('should remain deterministic for the same context', () async {
      final context = _buildContext(grossAmountMinor: 50000, currency: 'USD');

      final first = await workflow.execute(context);
      final second = await workflow.execute(context);

      expect(first.feeQuote.platformFeeMinor, second.feeQuote.platformFeeMinor);

      expect(first.feeQuote.vatMinor, second.feeQuote.vatMinor);

      expect(first.feeQuote.providerFeeMinor, second.feeQuote.providerFeeMinor);

      expect(first.feeQuote.expertNetMinor, second.feeQuote.expertNetMinor);

      expect(first.settledAt, second.settledAt);
    });

    test('should reject a zero gross amount', () {
      final context = _buildContext(grossAmountMinor: 0, currency: 'XOF');

      expect(() => workflow.execute(context), throwsArgumentError);
    });

    test('should reject a negative gross amount', () {
      final context = _buildContext(grossAmountMinor: -1000, currency: 'XOF');

      expect(() => workflow.execute(context), throwsArgumentError);
    });

    test('should reject an empty currency', () {
      final context = _buildContext(grossAmountMinor: 10000, currency: '   ');

      expect(() => workflow.execute(context), throwsArgumentError);
    });

    test('should reject an empty operation id', () {
      final context = _buildContext(operationId: '   ');

      expect(() => workflow.execute(context), throwsArgumentError);
    });

    test('should reject an empty consultation id', () {
      final context = _buildContext(consultationId: '');

      expect(() => workflow.execute(context), throwsArgumentError);
    });

    test('should reject an empty payment id', () {
      final context = _buildContext(paymentId: ' ');

      expect(() => workflow.execute(context), throwsArgumentError);
    });

    test('should reject an empty escrow id', () {
      final context = _buildContext(escrowId: ' ');

      expect(() => workflow.execute(context), throwsArgumentError);
    });

    test('should reject an empty client id', () {
      final context = _buildContext(clientId: ' ');

      expect(() => workflow.execute(context), throwsArgumentError);
    });

    test('should reject an empty expert id', () {
      final context = _buildContext(expertId: ' ');

      expect(() => workflow.execute(context), throwsArgumentError);
    });

    test('should implement the expected result contract', () async {
      final SettleConsultationResult result = await workflow.execute(
        _buildContext(),
      );

      expect(result.success, isTrue);
      expect(result.feeQuote.isBalanced, isTrue);
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
    metadata: const {'source': 'settle_consultation_workflow_test'},
  );
}
