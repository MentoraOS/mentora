import '../../primitives/percentage/percentage.dart';
import 'financial_rate.dart';

/// Strongly typed financial rate representing a Value Added Tax (VAT).
///
/// Using a dedicated type prevents VAT rates from being accidentally
/// mixed with commissions, platform fees or revenue shares.
final class VatRate extends FinancialRate {
  const VatRate._(super.percentage);

  /// Creates a VAT rate from an existing [Percentage].
  factory VatRate(Percentage percentage) {
    return VatRate._(percentage);
  }

  /// Creates a VAT rate from a whole percentage.
  factory VatRate.fromWholePercent(int wholePercent) {
    return VatRate._(Percentage.fromWholePercent(wholePercent));
  }

  /// Creates a VAT rate from basis points.
  factory VatRate.fromBasisPoints(int basisPoints) {
    return VatRate._(Percentage.fromBasisPoints(basisPoints));
  }

  /// Creates a VAT rate from parts per million.
  factory VatRate.fromPartsPerMillion(int partsPerMillion) {
    return VatRate._(Percentage.fromPartsPerMillion(partsPerMillion));
  }

  /// Creates a VAT rate from a textual representation.
  factory VatRate.parse(String value) {
    return VatRate._(Percentage.parse(value));
  }

  /// VAT rate equal to 0%.
  static const VatRate zero = VatRate._(Percentage.zero);
}
