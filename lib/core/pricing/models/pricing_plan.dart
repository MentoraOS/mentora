import 'pricing_type.dart';

class PricingPlan {
  final String id;
  final String expertId;

  final PricingType type;

  final String currency;

  final double amount;

  final bool active;

  const PricingPlan({
    required this.id,
    required this.expertId,
    required this.type,
    required this.currency,
    required this.amount,
    this.active = true,
  });

  bool get isPerMinute => type == PricingType.perMinute;

  bool get isPerHour => type == PricingType.perHour;

  bool get isFixed => type == PricingType.fixed;
}
