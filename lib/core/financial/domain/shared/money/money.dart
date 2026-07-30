import '../exceptions/currency_mismatch_exception.dart';
import '../exceptions/invalid_money_amount_exception.dart';
import 'financial_currency.dart';

/// Immutable, non-negative monetary value represented exclusively in minor
/// units.
///
/// `Money` intentionally does not accept `double`. Conversion from user-facing
/// decimal input belongs to an application/infrastructure mapper where rounding
/// rules can be made explicit.
final class Money implements Comparable<Money> {
  const Money._({required this.minorUnits, required this.currency});

  factory Money({
    required int minorUnits,
    required FinancialCurrency currency,
  }) {
    if (minorUnits < 0) {
      throw InvalidMoneyAmountException(minorUnits);
    }

    return Money._(minorUnits: minorUnits, currency: currency);
  }

  factory Money.zero(FinancialCurrency currency) =>
      Money._(minorUnits: 0, currency: currency);

  final int minorUnits;
  final FinancialCurrency currency;

  bool get isZero => minorUnits == 0;
  bool get isPositive => minorUnits > 0;

  Money add(Money other) {
    _requireSameCurrency(other);
    return Money._(
      minorUnits: minorUnits + other.minorUnits,
      currency: currency,
    );
  }

  /// Subtracts [other] while preserving the non-negative invariant.
  Money subtract(Money other) {
    _requireSameCurrency(other);
    final int result = minorUnits - other.minorUnits;
    if (result < 0) {
      throw InvalidMoneyAmountException(result);
    }
    return Money._(minorUnits: result, currency: currency);
  }

  Money operator +(Money other) => add(other);
  Money operator -(Money other) => subtract(other);

  bool isGreaterThan(Money other) => compareTo(other) > 0;
  bool isGreaterThanOrEqualTo(Money other) => compareTo(other) >= 0;
  bool isLessThan(Money other) => compareTo(other) < 0;
  bool isLessThanOrEqualTo(Money other) => compareTo(other) <= 0;

  @override
  int compareTo(Money other) {
    _requireSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  void _requireSameCurrency(Money other) {
    if (currency != other.currency) {
      throw CurrencyMismatchException(
        leftCurrency: currency.code,
        rightCurrency: other.currency.code,
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          other.minorUnits == minorUnits &&
          other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  String toString() => 'Money($minorUnits ${currency.code})';
}
