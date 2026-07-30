import '../models/fee_quote.dart';
import '../policies/fee_policy_registry.dart';

class FeeEngine {
  final FeePolicyRegistry registry;

  const FeeEngine({required this.registry});

  FeeQuote calculate({
    required String policyKey,
    required int grossAmountMinor,
    required String currency,
  }) {
    final policy = registry.resolve(policyKey);

    final quote = policy.calculate(
      grossAmountMinor: grossAmountMinor,
      currency: currency,
    );

    if (quote.grossAmountMinor != grossAmountMinor) {
      throw StateError(
        'Fee policy ${policy.key} changed the gross amount '
        'from $grossAmountMinor to ${quote.grossAmountMinor}',
      );
    }

    if (!quote.isBalanced) {
      throw StateError(
        'Fee policy ${policy.key} generated an unbalanced fee quote',
      );
    }

    return quote;
  }
}
