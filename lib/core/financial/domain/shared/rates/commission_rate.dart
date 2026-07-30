import '../../primitives/percentage/percentage.dart';
import 'financial_rate.dart';

/// Strongly typed financial rate representing a commission.
///
/// Examples:
///
/// - Platform commission
/// - Expert commission
/// - Affiliate commission
/// - Referral commission
///
/// Using a dedicated type prevents commission rates from being
/// accidentally mixed with VAT or other financial rates.
final class CommissionRate extends FinancialRate {
  const CommissionRate._(super.percentage);

  /// Creates a commission rate from an existing [Percentage].
  factory CommissionRate(Percentage percentage) {
    return CommissionRate._(percentage);
  }

  /// Creates a commission rate from a whole percentage.
  factory CommissionRate.fromWholePercent(int wholePercent) {
    return CommissionRate._(Percentage.fromWholePercent(wholePercent));
  }

  /// Creates a commission rate from basis points.
  factory CommissionRate.fromBasisPoints(int basisPoints) {
    return CommissionRate._(Percentage.fromBasisPoints(basisPoints));
  }

  /// Creates a commission rate from parts per million.
  factory CommissionRate.fromPartsPerMillion(int partsPerMillion) {
    return CommissionRate._(Percentage.fromPartsPerMillion(partsPerMillion));
  }

  /// Creates a commission rate from a textual representation.
  factory CommissionRate.parse(String value) {
    return CommissionRate._(Percentage.parse(value));
  }

  /// Commission rate equal to 0%.
  static const CommissionRate zero = CommissionRate._(Percentage.zero);
}
