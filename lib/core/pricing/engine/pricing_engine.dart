import '../domains/pricing_domain.dart';
import '../models/pricing_plan.dart';
import '../models/pricing_result.dart';

class PricingEngine {
  final PricingDomain domain;

  const PricingEngine({required this.domain});

  PricingResult quote({
    required String quoteId,
    required String consultationId,
    required PricingPlan plan,
    required Duration duration,
    double platformFeeRate = 0.15,
  }) {
    return domain.quote(
      quoteId: quoteId,
      consultationId: consultationId,
      plan: plan,
      duration: duration,
      platformFeeRate: platformFeeRate,
    );
  }
}
