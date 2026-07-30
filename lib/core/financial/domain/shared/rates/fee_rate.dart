import '../../primitives/percentage/percentage.dart';
import 'financial_rate.dart';

/// Strongly typed financial rate representing a fee.
///
/// Examples:
///
/// dart
/// final FeeRate platformFee =
///     FeeRate.fromWholePercent(10);
///
/// final FeeRate providerFee =
///     FeeRate.fromBasisPoints(75);
///
final class FeeRate extends FinancialRate {
  const FeeRate._(super.percentage);

  /// Creates a fee rate from an existing [Percentage].
  factory FeeRate(Percentage percentage) {
    return FeeRate._(percentage);
  }

  /// Creates a fee rate from a whole percentage.
  ///
  /// Example:
  ///
  /// dart
  /// FeeRate.fromWholePercent(10); // 10%
  ///
  factory FeeRate.fromWholePercent(int wholePercent) {
    return FeeRate._(Percentage.fromWholePercent(wholePercent));
  }

  /// Creates a fee rate from basis points.
  ///
  /// Example:
  ///
  /// dart
  /// FeeRate.fromBasisPoints(75); // 0.75%
  ///
  factory FeeRate.fromBasisPoints(int basisPoints) {
    return FeeRate._(Percentage.fromBasisPoints(basisPoints));
  }

  /// Creates a fee rate from parts per million.
  factory FeeRate.fromPartsPerMillion(int partsPerMillion) {
    return FeeRate._(Percentage.fromPartsPerMillion(partsPerMillion));
  }

  /// Creates a fee rate from a textual percentage.
  ///
  /// Example:
  ///
  /// dart
  /// FeeRate.parse('0.75'); // 0.75%
  ///
  factory FeeRate.parse(String value) {
    return FeeRate._(Percentage.parse(value));
  }

  /// Fee rate equal to 0%.
  static const FeeRate zero = FeeRate._(Percentage.zero);
}
