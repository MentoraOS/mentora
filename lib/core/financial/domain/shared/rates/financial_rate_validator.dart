import '../../primitives/percentage/percentage.dart';
import 'financial_rate.dart';
import 'rate_exception.dart';

/// Central validator for financial rates.
///
/// It centralizes reusable validation rules so that other financial
/// modules do not duplicate rate-related validations.
final class FinancialRateValidator {
  const FinancialRateValidator._();

  /// Ensures that a financial rate remains between 0% and 100%.
  static void validate(FinancialRate rate) {
    final int partsPerMillion = rate.percentage.partsPerMillion;

    if (partsPerMillion < Percentage.zero.partsPerMillion ||
        partsPerMillion > Percentage.partsPerMillionInOneHundredPercent) {
      throw const FinancialRateException(
        message: 'Financial rate must be between 0% and 100%.',
      );
    }
  }

  /// Ensures that all supplied rates are individually valid.
  static void validateAll(Iterable<FinancialRate> rates) {
    for (final FinancialRate rate in rates) {
      validate(rate);
    }
  }

  /// Ensures that multiple financial rates total exactly 100%.
  static void validateTotal(Iterable<FinancialRate> rates) {
    final List<FinancialRate> rateList = List<FinancialRate>.unmodifiable(
      rates,
    );

    if (rateList.isEmpty) {
      throw const FinancialRateException(
        message: 'At least one financial rate is required.',
      );
    }

    validateAll(rateList);

    final int totalPartsPerMillion = rateList.fold<int>(0, (
      int currentTotal,
      FinancialRate rate,
    ) {
      return currentTotal + rate.percentage.partsPerMillion;
    });

    if (totalPartsPerMillion != Percentage.partsPerMillionInOneHundredPercent) {
      throw FinancialRateException(
        message:
            'Financial rates must total exactly 100%. '
            'Current total: $totalPartsPerMillion ppm.',
        details: <String, Object?>{
          'expectedPartsPerMillion':
              Percentage.partsPerMillionInOneHundredPercent,
          'actualPartsPerMillion': totalPartsPerMillion,
        },
      );
    }
  }
}
