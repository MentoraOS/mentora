import '../../shared/money/money.dart';
import 'percentage_exception.dart';

/// Rounding strategies supported when a percentage is applied to Money.
enum FinancialRoundingMode {
  /// Always rounds toward zero.
  down,

  /// Rounds to the nearest minor unit.
  ///
  /// Exact halves are rounded upward.
  halfUp,

  /// Always rounds upward when a remainder exists.
  up,
}

final class Percentage implements Comparable<Percentage> {
  const Percentage._(this.partsPerMillion);

  static const int partsPerMillionInOneHundredPercent = 1000000;
  static const int partsPerMillionInOnePercent = 10000;

  /// Internal fixed-point representation.
  final int partsPerMillion;

  /// Percentage equal to 0%.
  static const Percentage zero = Percentage._(0);

  /// Percentage equal to 100%.
  static const Percentage oneHundred = Percentage._(
    partsPerMillionInOneHundredPercent,
  );

  /// Creates a percentage directly from parts per million.
  ///
  /// The default domain range is 0% to 100%, inclusive.
  factory Percentage.fromPartsPerMillion(int partsPerMillion) {
    if (partsPerMillion < 0) {
      throw InvalidPercentageException(
        message: 'Percentage cannot be negative.',
        value: partsPerMillion,
      );
    }

    if (partsPerMillion > partsPerMillionInOneHundredPercent) {
      throw InvalidPercentageException(
        message: 'Percentage cannot exceed 100%.',
        value: partsPerMillion,
      );
    }

    return Percentage._(partsPerMillion);
  }

  /// Creates a percentage from a whole percentage value.
  ///
  /// Examples:
  ///
  /// dart
  /// Percentage.fromWholePercent(18); // 18%
  /// Percentage.fromWholePercent(100); // 100%
  ///
  factory Percentage.fromWholePercent(int wholePercent) {
    return Percentage.fromPartsPerMillion(
      wholePercent * partsPerMillionInOnePercent,
    );
  }

  /// Creates a percentage from basis points.
  ///
  /// One basis point equals 0.01%.
  ///
  /// Examples:
  ///
  /// dart
  /// Percentage.fromBasisPoints(75); // 0.75%
  /// Percentage.fromBasisPoints(1800); // 18%
  ///
  factory Percentage.fromBasisPoints(int basisPoints) {
    return Percentage.fromPartsPerMillion(basisPoints * 100);
  }

  /// Creates a percentage from a textual decimal representation.
  ///
  /// The input represents a percentage value, not a fractional ratio.
  ///
  /// Examples:
  ///
  /// dart
  /// Percentage.parse('0.75'); // 0.75%
  /// Percentage.parse('18');   // 18%
  /// Percentage.parse('100');  // 100%
  ///
  factory Percentage.parse(String value) {
    final String normalized = value.trim().replaceAll(',', '.');

    if (normalized.isEmpty) {
      throw InvalidPercentageException(
        message: 'Percentage text cannot be empty.',
        value: value,
      );
    }

    final RegExp pattern = RegExp(r'^\d{1,3}(\.\d{1,4})?$');

    if (!pattern.hasMatch(normalized)) {
      throw InvalidPercentageException(
        message: 'Percentage must contain at most four decimal places.',
        value: value,
      );
    }

    final List<String> parts = normalized.split('.');
    final int wholePart = int.parse(parts.first);

    final String decimalText = parts.length == 1
        ? ''
        : parts.last.padRight(4, '0');

    final int decimalPart = decimalText.isEmpty ? 0 : int.parse(decimalText);

    final int ppm = (wholePart * partsPerMillionInOnePercent) + decimalPart;

    return Percentage.fromPartsPerMillion(ppm);
  }

  /// Returns the percentage expressed in basis points.
  ///
  /// Throws when the percentage cannot be represented exactly in basis
  /// points.
  int get basisPoints {
    if (partsPerMillion % 100 != 0) {
      throw InvalidPercentageException(
        message: 'Percentage cannot be represented exactly in basis points.',
        value: partsPerMillion,
      );
    }

    return partsPerMillion ~/ 100;
  }

  bool get isZero => partsPerMillion == 0;

  bool get isOneHundredPercent =>
      partsPerMillion == partsPerMillionInOneHundredPercent;

  /// Applies this percentage to a monetary amount.
  Money applyTo(
    Money amount, {
    FinancialRoundingMode roundingMode = FinancialRoundingMode.halfUp,
  }) {
    final int numerator = amount.minorUnits * partsPerMillion;

    final int roundedMinorUnits = _divideAndRound(
      numerator: numerator,
      denominator: partsPerMillionInOneHundredPercent,
      roundingMode: roundingMode,
    );

    return Money(minorUnits: roundedMinorUnits, currency: amount.currency);
  }

  Percentage operator +(Percentage other) {
    return Percentage.fromPartsPerMillion(
      partsPerMillion + other.partsPerMillion,
    );
  }

  Percentage operator -(Percentage other) {
    final int result = partsPerMillion - other.partsPerMillion;

    if (result < 0) {
      throw InvalidPercentageException(
        message: 'Percentage subtraction cannot produce a negative result.',
        value: result,
      );
    }

    return Percentage.fromPartsPerMillion(result);
  }

  @override
  int compareTo(Percentage other) {
    return partsPerMillion.compareTo(other.partsPerMillion);
  }

  bool operator <(Percentage other) => compareTo(other) < 0;

  bool operator <=(Percentage other) => compareTo(other) <= 0;

  bool operator >(Percentage other) => compareTo(other) > 0;

  bool operator >=(Percentage other) => compareTo(other) >= 0;

  int toPrimitive() => partsPerMillion;

  static int _divideAndRound({
    required int numerator,
    required int denominator,
    required FinancialRoundingMode roundingMode,
  }) {
    final int quotient = numerator ~/ denominator;
    final int remainder = numerator % denominator;

    if (remainder == 0) {
      return quotient;
    }

    return switch (roundingMode) {
      FinancialRoundingMode.down => quotient,
      FinancialRoundingMode.up => quotient + 1,
      FinancialRoundingMode.halfUp =>
        remainder * 2 >= denominator ? quotient + 1 : quotient,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Percentage && other.partsPerMillion == partsPerMillion;

  @override
  int get hashCode => partsPerMillion.hashCode;

  @override
  String toString() {
    final int whole = partsPerMillion ~/ partsPerMillionInOnePercent;

    final int fractional = partsPerMillion % partsPerMillionInOnePercent;

    if (fractional == 0) {
      return '$whole%';
    }

    final String fractionText = fractional
        .toString()
        .padLeft(4, '0')
        .replaceFirst(RegExp(r'0+$'), '');

    return '$whole.$fractionText%';
  }
}
