import '../models/pricing_plan.dart';
import '../models/pricing_result.dart';
import '../services/pricing_calculator_service.dart';

class PricingDomain {
  final PricingCalculatorService calculator;

  const PricingDomain({this.calculator = const PricingCalculatorService()});

  PricingResult quote({
    required String quoteId,
    required String consultationId,
    required PricingPlan plan,
    required Duration duration,
    double platformFeeRate = 0.15,
  }) {
    if (!plan.active) {
      return const PricingResult(
        success: false,
        message: 'Pricing plan is inactive',
      );
    }

    if (duration <= Duration.zero) {
      return const PricingResult(
        success: false,
        message: 'Duration must be greater than zero',
      );
    }

    if (plan.amount <= 0) {
      return const PricingResult(
        success: false,
        message: 'Pricing amount must be greater than zero',
      );
    }

    final quote = calculator.calculate(
      quoteId: quoteId,
      consultationId: consultationId,
      plan: plan,
      duration: duration,
      platformFeeRate: platformFeeRate,
    );

    return PricingResult(success: true, quote: quote);
  }
}
