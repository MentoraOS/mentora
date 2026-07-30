import '../models/fee_breakdown.dart';
import '../models/fee_component.dart';
import '../models/fee_quote.dart';
import 'fee_policy.dart';

class ConsultationFeePolicy extends FeePolicy {
  /// 1 500 basis points = 15 %.
  final int platformFeeBps;

  /// TVA appliquée sur la commission Mentora.
  /// 1 800 basis points = 18 %.
  final int vatOnPlatformFeeBps;

  /// Frais du fournisseur de paiement appliqués au montant brut.
  /// 100 basis points = 1 %.
  final int providerFeeBps;

  const ConsultationFeePolicy({
    this.platformFeeBps = 1500,
    this.vatOnPlatformFeeBps = 1800,
    this.providerFeeBps = 100,
  }) : assert(platformFeeBps >= 0 && platformFeeBps <= 10000),
       assert(vatOnPlatformFeeBps >= 0 && vatOnPlatformFeeBps <= 10000),
       assert(providerFeeBps >= 0 && providerFeeBps <= 10000);

  @override
  String get key => 'consultation';

  @override
  FeeQuote calculate({
    required int grossAmountMinor,
    required String currency,
  }) {
    if (grossAmountMinor <= 0) {
      throw ArgumentError.value(
        grossAmountMinor,
        'grossAmountMinor',
        'Gross amount must be greater than zero',
      );
    }

    final normalizedCurrency = currency.trim().toUpperCase();

    if (normalizedCurrency.isEmpty) {
      throw ArgumentError.value(
        currency,
        'currency',
        'Currency cannot be empty',
      );
    }

    final platformFeeMinor = _percentageOf(grossAmountMinor, platformFeeBps);

    final vatMinor = _percentageOf(platformFeeMinor, vatOnPlatformFeeBps);

    final providerFeeMinor = _percentageOf(grossAmountMinor, providerFeeBps);

    final totalDeductions = platformFeeMinor + vatMinor + providerFeeMinor;

    if (totalDeductions > grossAmountMinor) {
      throw StateError('Consultation fees exceed the gross amount');
    }

    final expertNetMinor = grossAmountMinor - totalDeductions;

    final breakdown = FeeBreakdown(
      components: [
        FeeComponent(
          code: 'PLATFORM_FEE',
          label: 'Mentora platform fee',
          amountMinor: platformFeeMinor,
        ),
        FeeComponent(
          code: 'VAT',
          label: 'VAT on platform fee',
          amountMinor: vatMinor,
        ),
        FeeComponent(
          code: 'PAYMENT_PROVIDER_FEE',
          label: 'Payment provider fee',
          amountMinor: providerFeeMinor,
        ),
        FeeComponent(
          code: 'EXPERT_NET',
          label: 'Expert net amount',
          amountMinor: expertNetMinor,
        ),
      ],
    );

    final quote = FeeQuote(
      grossAmountMinor: grossAmountMinor,
      platformFeeMinor: platformFeeMinor,
      vatMinor: vatMinor,
      providerFeeMinor: providerFeeMinor,
      expertNetMinor: expertNetMinor,
      currency: normalizedCurrency,
      breakdown: breakdown,
    );

    if (!quote.isBalanced) {
      throw StateError('Generated consultation fee quote is unbalanced');
    }

    return quote;
  }

  int _percentageOf(int amountMinor, int basisPoints) {
    // Arrondi déterministe au plus proche.
    return (amountMinor * basisPoints + 5000) ~/ 10000;
  }
}
