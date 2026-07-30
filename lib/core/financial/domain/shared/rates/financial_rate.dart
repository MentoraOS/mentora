import '../../primitives/percentage/percentage.dart';

/// Base class for all financial rates used throughout the Financial Domain.
///
/// A FinancialRate is a strongly typed wrapper around a [Percentage].
///
/// Examples:
///
/// - FeeRate
/// - VatRate
/// - CommissionRate
/// - RevenueShare
///
/// Using dedicated rate types prevents accidentally mixing different
/// financial concepts.
abstract base class FinancialRate implements Comparable<FinancialRate> {
  const FinancialRate(this.percentage);

  /// Underlying immutable percentage.
  final Percentage percentage;

  /// Returns true if the rate equals 0%.
  bool get isZero => percentage.isZero;

  /// Returns true if the rate equals 100%.
  bool get isOneHundredPercent => percentage.isOneHundredPercent;

  /// Returns the raw fixed-point representation.
  int toPrimitive() => percentage.toPrimitive();

  @override
  int compareTo(FinancialRate other) {
    return percentage.compareTo(other.percentage);
  }

  bool operator <(FinancialRate other) => compareTo(other) < 0;

  bool operator <=(FinancialRate other) => compareTo(other) <= 0;

  bool operator >(FinancialRate other) => compareTo(other) > 0;

  bool operator >=(FinancialRate other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          other is FinancialRate &&
          other.percentage == percentage;

  @override
  int get hashCode => Object.hash(runtimeType, percentage);

  @override
  String toString() => '$runtimeType($percentage)';
}
