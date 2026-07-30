import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/fees/policies/consultation_fee_policy.dart';

void main() {
  group('ConsultationFeePolicy', () {
    test('should calculate the default consultation fee breakdown', () {
      const policy = ConsultationFeePolicy();

      final quote = policy.calculate(grossAmountMinor: 10000, currency: 'xof');

      expect(quote.grossAmountMinor, 10000);
      expect(quote.currency, 'XOF');

      expect(quote.platformFeeMinor, 1500);
      expect(quote.vatMinor, 270);
      expect(quote.providerFeeMinor, 100);
      expect(quote.expertNetMinor, 8130);

      expect(quote.isBalanced, isTrue);
      expect(quote.breakdown.totalMinor, 10000);
      expect(quote.breakdown.components.length, 4);
    });

    test('should expose every fee component by code', () {
      const policy = ConsultationFeePolicy();

      final quote = policy.calculate(grossAmountMinor: 10000, currency: 'USD');

      final platformFee = quote.breakdown.byCode('PLATFORM_FEE');

      final vat = quote.breakdown.byCode('VAT');

      final providerFee = quote.breakdown.byCode('PAYMENT_PROVIDER_FEE');

      final expertNet = quote.breakdown.byCode('EXPERT_NET');

      expect(platformFee, isNotNull);
      expect(platformFee!.amountMinor, 1500);

      expect(vat, isNotNull);
      expect(vat!.amountMinor, 270);

      expect(providerFee, isNotNull);
      expect(providerFee!.amountMinor, 100);

      expect(expertNet, isNotNull);
      expect(expertNet!.amountMinor, 8130);
    });

    test('should support custom basis point configuration', () {
      const policy = ConsultationFeePolicy(
        platformFeeBps: 1000,
        vatOnPlatformFeeBps: 1800,
        providerFeeBps: 200,
      );

      final quote = policy.calculate(grossAmountMinor: 10000, currency: 'USD');

      expect(quote.platformFeeMinor, 1000);
      expect(quote.vatMinor, 180);
      expect(quote.providerFeeMinor, 200);
      expect(quote.expertNetMinor, 8620);
      expect(quote.isBalanced, isTrue);
    });

    test('should round percentage values deterministically', () {
      const policy = ConsultationFeePolicy(
        platformFeeBps: 1500,
        vatOnPlatformFeeBps: 1800,
        providerFeeBps: 100,
      );

      final quote = policy.calculate(grossAmountMinor: 9999, currency: 'USD');

      expect(quote.platformFeeMinor, 1500);
      expect(quote.vatMinor, 270);
      expect(quote.providerFeeMinor, 100);
      expect(quote.expertNetMinor, 8129);
      expect(quote.isBalanced, isTrue);
    });

    test('should allow a zero-rate configuration', () {
      const policy = ConsultationFeePolicy(
        platformFeeBps: 0,
        vatOnPlatformFeeBps: 0,
        providerFeeBps: 0,
      );

      final quote = policy.calculate(grossAmountMinor: 10000, currency: 'USD');

      expect(quote.platformFeeMinor, 0);
      expect(quote.vatMinor, 0);
      expect(quote.providerFeeMinor, 0);
      expect(quote.expertNetMinor, 10000);
      expect(quote.isBalanced, isTrue);
    });

    test('should reject a zero gross amount', () {
      const policy = ConsultationFeePolicy();

      expect(
        () => policy.calculate(grossAmountMinor: 0, currency: 'USD'),
        throwsArgumentError,
      );
    });

    test('should reject a negative gross amount', () {
      const policy = ConsultationFeePolicy();

      expect(
        () => policy.calculate(grossAmountMinor: -1000, currency: 'USD'),
        throwsArgumentError,
      );
    });

    test('should reject an empty currency', () {
      const policy = ConsultationFeePolicy();

      expect(
        () => policy.calculate(grossAmountMinor: 10000, currency: '   '),
        throwsArgumentError,
      );
    });

    test('should reject fees greater than the gross amount', () {
      const policy = ConsultationFeePolicy(
        platformFeeBps: 9000,
        vatOnPlatformFeeBps: 5000,
        providerFeeBps: 2000,
      );

      expect(
        () => policy.calculate(grossAmountMinor: 10000, currency: 'USD'),
        throwsStateError,
      );
    });
  });
}
