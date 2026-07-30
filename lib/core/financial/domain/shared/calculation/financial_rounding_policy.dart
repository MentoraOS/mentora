import 'financial_rounding_mode.dart';

final class FinancialRoundingPolicy {
  const FinancialRoundingPolicy({this.mode = FinancialRoundingMode.halfUp});

  final FinancialRoundingMode mode;

  static const standard = FinancialRoundingPolicy();

  static const providerFees = FinancialRoundingPolicy(
    mode: FinancialRoundingMode.up,
  );

  static const taxes = FinancialRoundingPolicy(
    mode: FinancialRoundingMode.halfUp,
  );

  static const payouts = FinancialRoundingPolicy(
    mode: FinancialRoundingMode.down,
  );
}
