import 'fee_breakdown.dart';

class FeeQuote {
  final int grossAmountMinor;

  final int platformFeeMinor;

  final int vatMinor;

  final int providerFeeMinor;

  final int expertNetMinor;

  final String currency;

  final FeeBreakdown breakdown;

  const FeeQuote({
    required this.grossAmountMinor,
    required this.platformFeeMinor,
    required this.vatMinor,
    required this.providerFeeMinor,
    required this.expertNetMinor,
    required this.currency,
    required this.breakdown,
  });

  bool get isBalanced =>
      grossAmountMinor ==
      platformFeeMinor + vatMinor + providerFeeMinor + expertNetMinor;
}
