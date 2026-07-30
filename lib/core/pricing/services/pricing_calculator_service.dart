import '../models/pricing_plan.dart';
import '../models/pricing_quote.dart';
import '../models/pricing_type.dart';

class PricingCalculatorService {
  const PricingCalculatorService();

  PricingQuote calculate({
    required String quoteId,
    required String consultationId,
    required PricingPlan plan,
    required Duration duration,
    double platformFeeRate = 0.15,
  }) {
    double subtotal = 0;

    switch (plan.type) {
      case PricingType.perMinute:
        subtotal = plan.amount * duration.inMinutes;
        break;

      case PricingType.perHour:
        subtotal = plan.amount * (duration.inMinutes / 60);
        break;

      case PricingType.fixed:
        subtotal = plan.amount;
        break;
    }

    final platformFee = subtotal * platformFeeRate;

    final total = subtotal + platformFee;

    return PricingQuote(
      id: quoteId,
      expertId: plan.expertId,
      consultationId: consultationId,
      currency: plan.currency,
      duration: duration,
      subtotal: subtotal,
      platformFee: platformFee,
      total: total,
    );
  }
}
