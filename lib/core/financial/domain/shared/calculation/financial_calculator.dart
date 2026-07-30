import '../../primitives/percentage/percentage.dart';
import '../money/money.dart';
import 'financial_calculation_exception.dart';
import 'financial_rounding_mode.dart' as shared_rounding;
import 'financial_rounding_policy.dart';

/// Central domain service responsible for deterministic financial calculations.
///
/// This service performs all monetary calculations using integer minor units.
/// It deliberately avoids floating-point values to preserve financial precision.
///
/// Every monetary result preserves the currency of the original amount.
final class FinancialCalculator {
  const FinancialCalculator._();

  /// Calculates a percentage of [amount].
  ///
  /// Example:
  ///
  /// dart
  /// final Money platformFee =
  ///     FinancialCalculator.calculatePercentage(
  ///   amount,
  ///   Percentage.fromWholePercent(10),
  /// );
  ///
  ///
  /// The returned value uses the same currency as [amount].
  static Money calculatePercentage(
    Money amount,
    Percentage percentage, {
    FinancialRoundingPolicy policy = FinancialRoundingPolicy.standard,
  }) {
    try {
      final int numerator = amount.minorUnits * percentage.partsPerMillion;

      final int resultMinorUnits = _divideAndRound(
        numerator: numerator,
        denominator: Percentage.partsPerMillionInOneHundredPercent,
        mode: policy.mode,
      );

      return Money(minorUnits: resultMinorUnits, currency: amount.currency);
    } on FinancialCalculationException {
      rethrow;
    } catch (error) {
      throw FinancialCalculationException(
        message: 'Unable to calculate percentage: ${error.runtimeType}: $error',
      );
    }
  }

  /// Subtracts a calculated percentage from [amount].
  ///
  /// This method can be used to calculate:
  ///
  /// - net payouts;
  /// - remaining balances;
  /// - amounts after platform commission;
  /// - amounts after provider fees;
  /// - amounts after taxation.
  ///
  /// Example:
  ///
  /// dart
  /// final Money netAmount =
  ///     FinancialCalculator.subtractPercentage(
  ///   grossAmount,
  ///   Percentage.fromWholePercent(15),
  /// );
  ///
  static Money subtractPercentage(
    Money amount,
    Percentage percentage, {
    FinancialRoundingPolicy policy = FinancialRoundingPolicy.standard,
  }) {
    final Money calculatedAmount = calculatePercentage(
      amount,
      percentage,
      policy: policy,
    );

    return amount.subtract(calculatedAmount);
  }

  /// Adds a calculated percentage to [amount].
  ///
  /// This can be used for taxes, markups or additional financial charges.
  static Money addPercentage(
    Money amount,
    Percentage percentage, {
    FinancialRoundingPolicy policy = FinancialRoundingPolicy.standard,
  }) {
    final Money calculatedAmount = calculatePercentage(
      amount,
      percentage,
      policy: policy,
    );

    return amount.add(calculatedAmount);
  }

  /// Divides two integer values and applies a deterministic rounding mode.
  ///
  /// Floating-point arithmetic is intentionally avoided.
  static int _divideAndRound({
    required int numerator,
    required int denominator,
    required shared_rounding.FinancialRoundingMode mode,
  }) {
    if (denominator <= 0) {
      throw const FinancialCalculationException(
        message: 'The calculation denominator must be greater than zero.',
      );
    }

    if (numerator < 0) {
      throw const FinancialCalculationException(
        message: 'The calculation numerator cannot be negative.',
      );
    }

    if (numerator == 0) {
      return 0;
    }

    final int quotient = numerator ~/ denominator;
    final int remainder = numerator % denominator;

    if (remainder == 0) {
      return quotient;
    }

    return switch (mode) {
      shared_rounding.FinancialRoundingMode.down => quotient,
      shared_rounding.FinancialRoundingMode.halfUp =>
        remainder * 2 >= denominator ? quotient + 1 : quotient,
      shared_rounding.FinancialRoundingMode.up => quotient + 1,
    };
  }
}
