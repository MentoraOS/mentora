import '../exceptions/invalid_financial_currency_exception.dart';

/// Immutable ISO-4217 currency value used throughout the financial domain.
///
/// The constructor is intentionally private: only currencies explicitly
/// supported by Mentora can enter the domain. Adding a new country therefore
/// means registering its currency here rather than accepting arbitrary strings.
final class FinancialCurrency implements Comparable<FinancialCurrency> {
  const FinancialCurrency._({
    required this.code,
    required this.name,
    required this.symbol,
    required this.minorUnitDigits,
  });

  final String code;
  final String name;
  final String symbol;
  final int minorUnitDigits;

  static const FinancialCurrency xof = FinancialCurrency._(
    code: 'XOF',
    name: 'West African CFA franc',
    symbol: 'FCFA',
    minorUnitDigits: 0,
  );

  static const FinancialCurrency usd = FinancialCurrency._(
    code: 'USD',
    name: 'United States dollar',
    symbol: r'$',
    minorUnitDigits: 2,
  );

  static const FinancialCurrency eur = FinancialCurrency._(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    minorUnitDigits: 2,
  );

  static const FinancialCurrency gbp = FinancialCurrency._(
    code: 'GBP',
    name: 'Pound sterling',
    symbol: '£',
    minorUnitDigits: 2,
  );

  static const FinancialCurrency ngn = FinancialCurrency._(
    code: 'NGN',
    name: 'Nigerian naira',
    symbol: '₦',
    minorUnitDigits: 2,
  );

  static const FinancialCurrency ghs = FinancialCurrency._(
    code: 'GHS',
    name: 'Ghanaian cedi',
    symbol: 'GH₵',
    minorUnitDigits: 2,
  );

  static const FinancialCurrency kes = FinancialCurrency._(
    code: 'KES',
    name: 'Kenyan shilling',
    symbol: 'KSh',
    minorUnitDigits: 2,
  );

  static const List<FinancialCurrency> supported = <FinancialCurrency>[
    xof,
    usd,
    eur,
    gbp,
    ngn,
    ghs,
    kes,
  ];

  static final Map<String, FinancialCurrency> _byCode =
      <String, FinancialCurrency>{
        for (final FinancialCurrency currency in supported)
          currency.code: currency,
      };

  /// Resolves a supported currency from an ISO code.
  ///
  /// Input is normalized by trimming whitespace and upper-casing it.
  static FinancialCurrency fromCode(String code) {
    final String normalized = code.trim().toUpperCase();
    final FinancialCurrency? currency = _byCode[normalized];
    if (currency == null) {
      throw InvalidFinancialCurrencyException(code);
    }
    return currency;
  }

  /// Resolves a supported currency, or returns `null` when it is unknown.
  static FinancialCurrency? tryFromCode(String? code) {
    if (code == null) {
      return null;
    }
    return _byCode[code.trim().toUpperCase()];
  }

  /// Number of minor units in one major unit (1 for XOF, 100 for USD, etc.).
  int get minorUnitFactor {
    var factor = 1;
    for (var index = 0; index < minorUnitDigits; index += 1) {
      factor *= 10;
    }
    return factor;
  }

  @override
  int compareTo(FinancialCurrency other) => code.compareTo(other.code);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialCurrency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => code;
}
