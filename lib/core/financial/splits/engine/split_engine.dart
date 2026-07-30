import '../../fees/models/fee_quote.dart';
import '../models/settlement_split.dart';
import '../models/settlement_split_component.dart';
import '../models/split_destination.dart';

class SplitEngine {
  const SplitEngine();

  SettlementSplit build({required FeeQuote feeQuote}) {
    _validateFeeQuote(feeQuote);

    final normalizedCurrency = feeQuote.currency.trim().toUpperCase();

    final split = SettlementSplit(
      grossAmountMinor: feeQuote.grossAmountMinor,
      currency: normalizedCurrency,
      components: [
        SettlementSplitComponent(
          destination: SplitDestination.expertWallet,
          amountMinor: feeQuote.expertNetMinor,
          code: 'EXPERT_NET',
          label: 'Expert net amount',
        ),
        SettlementSplitComponent(
          destination: SplitDestination.platformRevenue,
          amountMinor: feeQuote.platformFeeMinor,
          code: 'PLATFORM_FEE',
          label: 'Mentora platform revenue',
        ),
        SettlementSplitComponent(
          destination: SplitDestination.taxPayable,
          amountMinor: feeQuote.vatMinor,
          code: 'VAT',
          label: 'VAT payable',
        ),
        SettlementSplitComponent(
          destination: SplitDestination.paymentProviderFee,
          amountMinor: feeQuote.providerFeeMinor,
          code: 'PAYMENT_PROVIDER_FEE',
          label: 'Payment provider fee',
        ),
      ],
    );

    if (!split.isBalanced) {
      throw StateError(
        'Generated settlement split is unbalanced: '
        'gross=${split.grossAmountMinor}, '
        'total=${split.totalMinor}',
      );
    }

    return split;
  }

  void _validateFeeQuote(FeeQuote feeQuote) {
    if (feeQuote.grossAmountMinor <= 0) {
      throw ArgumentError.value(
        feeQuote.grossAmountMinor,
        'grossAmountMinor',
        'Gross amount must be greater than zero',
      );
    }

    if (feeQuote.currency.trim().isEmpty) {
      throw ArgumentError.value(
        feeQuote.currency,
        'currency',
        'Currency cannot be empty',
      );
    }

    if (feeQuote.platformFeeMinor < 0 ||
        feeQuote.vatMinor < 0 ||
        feeQuote.providerFeeMinor < 0 ||
        feeQuote.expertNetMinor < 0) {
      throw StateError('Fee quote contains a negative component');
    }

    if (!feeQuote.isBalanced) {
      throw StateError('Cannot build a split from an unbalanced fee quote');
    }

    if (feeQuote.breakdown.totalMinor != feeQuote.grossAmountMinor) {
      throw StateError(
        'Fee breakdown total '
        '${feeQuote.breakdown.totalMinor} does not equal '
        'gross amount ${feeQuote.grossAmountMinor}',
      );
    }
  }
}
