import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/pricing/domains/pricing_domain.dart';
import 'package:mentora/core/pricing/models/pricing_plan.dart';
import 'package:mentora/core/pricing/models/pricing_type.dart';

void main() {
  group('Pricing Domain', () {
    test('should calculate per minute pricing', () {
      const domain = PricingDomain();

      const plan = PricingPlan(
        id: 'plan_001',
        expertId: 'expert_001',
        type: PricingType.perMinute,
        currency: 'USD',
        amount: 2,
      );

      final result = domain.quote(
        quoteId: 'quote_001',
        consultationId: 'consultation_001',
        plan: plan,
        duration: const Duration(minutes: 30),
        platformFeeRate: 0.15,
      );

      expect(result.success, isTrue);
      expect(result.quote?.subtotal, 60);
      expect(result.quote?.platformFee, 9);
      expect(result.quote?.total, 69);
    });

    test('should calculate per hour pricing', () {
      const domain = PricingDomain();

      const plan = PricingPlan(
        id: 'plan_002',
        expertId: 'expert_001',
        type: PricingType.perHour,
        currency: 'USD',
        amount: 120,
      );

      final result = domain.quote(
        quoteId: 'quote_002',
        consultationId: 'consultation_002',
        plan: plan,
        duration: const Duration(minutes: 30),
      );

      expect(result.success, isTrue);
      expect(result.quote?.subtotal, 60);
      expect(result.quote?.platformFee, 9);
      expect(result.quote?.total, 69);
    });

    test('should calculate fixed pricing', () {
      const domain = PricingDomain();

      const plan = PricingPlan(
        id: 'plan_003',
        expertId: 'expert_001',
        type: PricingType.fixed,
        currency: 'USD',
        amount: 100,
      );

      final result = domain.quote(
        quoteId: 'quote_003',
        consultationId: 'consultation_003',
        plan: plan,
        duration: const Duration(minutes: 45),
      );

      expect(result.success, isTrue);
      expect(result.quote?.subtotal, 100);
      expect(result.quote?.platformFee, 15);
      expect(result.quote?.total, 115);
    });

    test('should reject inactive pricing plan', () {
      const domain = PricingDomain();

      const plan = PricingPlan(
        id: 'plan_004',
        expertId: 'expert_001',
        type: PricingType.perMinute,
        currency: 'USD',
        amount: 2,
        active: false,
      );

      final result = domain.quote(
        quoteId: 'quote_004',
        consultationId: 'consultation_004',
        plan: plan,
        duration: const Duration(minutes: 30),
      );

      expect(result.success, isFalse);
    });

    test('should reject invalid duration', () {
      const domain = PricingDomain();

      const plan = PricingPlan(
        id: 'plan_005',
        expertId: 'expert_001',
        type: PricingType.perMinute,
        currency: 'USD',
        amount: 2,
      );

      final result = domain.quote(
        quoteId: 'quote_005',
        consultationId: 'consultation_005',
        plan: plan,
        duration: Duration.zero,
      );

      expect(result.success, isFalse);
    });
  });
}
