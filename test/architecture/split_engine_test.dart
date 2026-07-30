import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/fees/engine/fee_engine.dart';
import 'package:mentora/core/financial/fees/models/fee_breakdown.dart';
import 'package:mentora/core/financial/fees/models/fee_quote.dart';
import 'package:mentora/core/financial/fees/policies/consultation_fee_policy.dart';
import 'package:mentora/core/financial/fees/policies/fee_policy_registry.dart';

import 'package:mentora/core/financial/splits/engine/split_engine.dart';
import 'package:mentora/core/financial/splits/models/split_destination.dart';

void main() {
  group('SplitEngine', () {
    late FeePolicyRegistry feePolicyRegistry;
    late FeeEngine feeEngine;
    late SplitEngine splitEngine;

    setUp(() {
      feePolicyRegistry = FeePolicyRegistry();

      feePolicyRegistry.register(const ConsultationFeePolicy());

      feeEngine = FeeEngine(registry: feePolicyRegistry);

      splitEngine = const SplitEngine();
    });

    test('should transform a fee quote into a balanced settlement split', () {
      final quote = _buildQuote(
        feeEngine: feeEngine,
        grossAmountMinor: 10000,
        currency: 'XOF',
      );

      final split = splitEngine.build(feeQuote: quote);

      expect(split.grossAmountMinor, 10000);
      expect(split.currency, 'XOF');

      expect(split.components.length, 4);

      expect(split.totalMinor, 10000);
      expect(split.isBalanced, isTrue);
    });

    test('should allocate expert net to expert wallet', () {
      final split = splitEngine.build(
        feeQuote: _buildQuote(feeEngine: feeEngine),
      );

      final component = split.byDestination(SplitDestination.expertWallet);

      expect(component, isNotNull);
      expect(component!.amountMinor, 8130);
      expect(component.code, 'EXPERT_NET');
    });

    test('should allocate platform fee to platform revenue', () {
      final split = splitEngine.build(
        feeQuote: _buildQuote(feeEngine: feeEngine),
      );

      final component = split.byDestination(SplitDestination.platformRevenue);

      expect(component, isNotNull);
      expect(component!.amountMinor, 1500);
      expect(component.code, 'PLATFORM_FEE');
    });

    test('should allocate VAT to tax payable', () {
      final split = splitEngine.build(
        feeQuote: _buildQuote(feeEngine: feeEngine),
      );

      final component = split.byDestination(SplitDestination.taxPayable);

      expect(component, isNotNull);
      expect(component!.amountMinor, 270);
      expect(component.code, 'VAT');
    });

    test('should allocate provider fee correctly', () {
      final split = splitEngine.build(
        feeQuote: _buildQuote(feeEngine: feeEngine),
      );

      final component = split.byDestination(
        SplitDestination.paymentProviderFee,
      );

      expect(component, isNotNull);
      expect(component!.amountMinor, 100);
      expect(component.code, 'PAYMENT_PROVIDER_FEE');
    });

    test('should normalize currency', () {
      final quote = _buildQuote(feeEngine: feeEngine, currency: 'usd');

      final split = splitEngine.build(feeQuote: quote);

      expect(split.currency, 'USD');
    });

    test('should remain deterministic', () {
      final quote = _buildQuote(
        feeEngine: feeEngine,
        grossAmountMinor: 50000,
        currency: 'EUR',
      );

      final first = splitEngine.build(feeQuote: quote);

      final second = splitEngine.build(feeQuote: quote);

      expect(first.totalMinor, second.totalMinor);
      expect(first.isBalanced, second.isBalanced);
      expect(first.components.length, second.components.length);

      for (int i = 0; i < first.components.length; i++) {
        expect(
          first.components[i].destination,
          second.components[i].destination,
        );

        expect(
          first.components[i].amountMinor,
          second.components[i].amountMinor,
        );
      }
    });

    test('should support zero rate consultation', () {
      final registry = FeePolicyRegistry();

      registry.register(
        const ConsultationFeePolicy(
          platformFeeBps: 0,
          vatOnPlatformFeeBps: 0,
          providerFeeBps: 0,
        ),
      );

      final zeroEngine = FeeEngine(registry: registry);

      final quote = zeroEngine.calculate(
        policyKey: 'consultation',
        grossAmountMinor: 10000,
        currency: 'XOF',
      );

      final split = splitEngine.build(feeQuote: quote);

      expect(split.amountFor(SplitDestination.expertWallet), 10000);

      expect(split.amountFor(SplitDestination.platformRevenue), 0);

      expect(split.isBalanced, isTrue);
    });

    test('should reject unbalanced fee quote', () {
      const invalidQuote = FeeQuote(
        grossAmountMinor: 10000,
        platformFeeMinor: 1500,
        vatMinor: 270,
        providerFeeMinor: 100,
        expertNetMinor: 8000,
        currency: 'XOF',
        breakdown: FeeBreakdown(components: []),
      );

      expect(() => splitEngine.build(feeQuote: invalidQuote), throwsStateError);
    });
  });
}

FeeQuote _buildQuote({
  required FeeEngine feeEngine,
  int grossAmountMinor = 10000,
  String currency = 'XOF',
}) {
  return feeEngine.calculate(
    policyKey: 'consultation',
    grossAmountMinor: grossAmountMinor,
    currency: currency,
  );
}
