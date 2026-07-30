class PricingQuote {
  final String id;
  final String expertId;
  final String consultationId;

  final String currency;

  final Duration duration;

  final double subtotal;
  final double platformFee;
  final double total;

  const PricingQuote({
    required this.id,
    required this.expertId,
    required this.consultationId,
    required this.currency,
    required this.duration,
    required this.subtotal,
    required this.platformFee,
    required this.total,
  });
}
