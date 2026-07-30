import '../../primitives/percentage/percentage.dart';
import '../money/money.dart';

/// Immutable result representing one portion of a financial allocation.
///
/// [T] identifies the beneficiary or purpose of the allocation.
///
/// Examples of allocation keys:
///
/// - an enum representing expert or platform;
/// - a typed financial identifier;
/// - a dedicated domain value object.
///
/// Example:
///
/// dart
/// final allocation = FinancialAllocation&lt;String&gt;(
///   key: 'expert',
///   rate: RevenueShare.fromWholePercent(85).percentage,
///   amount: Money(
///     minorUnits: 8500,
///     currency: FinancialCurrency.xof,
///   ),
/// );
///
final class FinancialAllocation<T> {
  const FinancialAllocation({
    required this.key,
    required this.rate,
    required this.amount,
  });

  /// Identifier of the beneficiary or allocation purpose.
  final T key;

  /// Percentage used to calculate this allocation.
  final Percentage rate;

  /// Final monetary amount assigned to this allocation.
  final Money amount;

  /// Returns true when the allocated amount is zero.
  bool get isZero => amount.isZero;

  /// Returns true when the allocated amount is greater than zero.
  bool get isPositive => amount.isPositive;

  /// Returns a copy with selected values replaced.
  FinancialAllocation<T> copyWith({T? key, Percentage? rate, Money? amount}) {
    return FinancialAllocation<T>(
      key: key ?? this.key,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FinancialAllocation<T> &&
            other.key == key &&
            other.rate == rate &&
            other.amount == amount;
  }

  @override
  int get hashCode => Object.hash(key, rate, amount);

  @override
  String toString() {
    return 'FinancialAllocation<$T>('
        'key: $key, '
        'rate: $rate, '
        'amount: $amount'
        ')';
  }
}
