import '../../primitives/percentage/percentage.dart';
import 'financial_rate.dart';

/// Strongly typed financial rate representing a revenue share.
///
/// RevenueShare defines how revenue is distributed between
/// stakeholders (platform, expert, partner, affiliate, etc.).
///
/// This type is intentionally distinct from FeeRate and
/// CommissionRate to enforce business semantics.
final class RevenueShare extends FinancialRate {
  const RevenueShare._(super.percentage);

  /// Creates a revenue share from an existing [Percentage].
  factory RevenueShare(Percentage percentage) {
    return RevenueShare._(percentage);
  }

  /// Creates a revenue share from a whole percentage.
  factory RevenueShare.fromWholePercent(int wholePercent) {
    return RevenueShare._(Percentage.fromWholePercent(wholePercent));
  }

  /// Creates a revenue share from basis points.
  factory RevenueShare.fromBasisPoints(int basisPoints) {
    return RevenueShare._(Percentage.fromBasisPoints(basisPoints));
  }

  /// Creates a revenue share from parts per million.
  factory RevenueShare.fromPartsPerMillion(int partsPerMillion) {
    return RevenueShare._(Percentage.fromPartsPerMillion(partsPerMillion));
  }

  /// Creates a revenue share from a textual representation.
  factory RevenueShare.parse(String value) {
    return RevenueShare._(Percentage.parse(value));
  }

  /// Revenue share equal to 0%.
  static const RevenueShare zero = RevenueShare._(Percentage.zero);
}
