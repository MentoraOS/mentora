import 'pricing_quote.dart';

class PricingResult {
  final bool success;
  final String? message;
  final PricingQuote? quote;

  const PricingResult({required this.success, this.message, this.quote});
}
