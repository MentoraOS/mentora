import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/fees/engine/fee_engine.dart';
import 'package:mentora/core/financial/fees/models/fee_quote.dart';
import 'package:mentora/core/financial/fees/policies/consultation_fee_policy.dart';
import 'package:mentora/core/financial/fees/policies/fee_policy_registry.dart';

void main() {
  group('FeeEngine', () {
    late FeePolicyRegistry registry;
    late FeeEngine engine;

    setUp(() {
      registry = FeePolicyRegistry();

      registry.register(const ConsultationFeePolicy());

      engine = FeeEngine(registry: registry);
    });

    test('should calculate consultation fees', () {
      final FeeQuote quote = engine.calculate(
        policyKey: 'consultation',
        grossAmountMinor: 10000,
        currency: 'XOF',
      );

      expect(quote.platformFeeMinor, 1500);
      expect(quote.vatMinor, 270);
      expect(quote.providerFeeMinor, 100);
      expect(quote.expertNetMinor, 8130);
      expect(quote.isBalanced, isTrue);
    });

    test('should normalize policy key', () {
      final quote = engine.calculate(
        policyKey: ' Consultation ',
        grossAmountMinor: 10000,
        currency: 'XOF',
      );

      expect(quote.expertNetMinor, 8130);
    });

    test('should reject an unknown policy', () {
      expect(
        () => engine.calculate(
          policyKey: 'subscription',
          grossAmountMinor: 10000,
          currency: 'XOF',
        ),
        throwsStateError,
      );
    });

    test('should reject empty policy key', () {
      expect(
        () => engine.calculate(
          policyKey: '',
          grossAmountMinor: 10000,
          currency: 'XOF',
        ),
        throwsArgumentError,
      );
    });

    test('should remain deterministic', () {
      final first = engine.calculate(
        policyKey: 'consultation',
        grossAmountMinor: 35000,
        currency: 'USD',
      );

      final second = engine.calculate(
        policyKey: 'consultation',
        grossAmountMinor: 35000,
        currency: 'USD',
      );

      expect(first.platformFeeMinor, second.platformFeeMinor);

      expect(first.providerFeeMinor, second.providerFeeMinor);

      expect(first.vatMinor, second.vatMinor);

      expect(first.expertNetMinor, second.expertNetMinor);
    });

    test('should support multiple calculations', () {
      for (var i = 1; i <= 100; i++) {
        final quote = engine.calculate(
          policyKey: 'consultation',
          grossAmountMinor: i * 1000,
          currency: 'USD',
        );

        expect(quote.isBalanced, isTrue);
      }
    });

    test('should preserve gross amount', () {
      final quote = engine.calculate(
        policyKey: 'consultation',
        grossAmountMinor: 250000,
        currency: 'EUR',
      );

      expect(quote.grossAmountMinor, 250000);
    });
  });
}
