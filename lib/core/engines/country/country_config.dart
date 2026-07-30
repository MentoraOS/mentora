class CountryConfig {
  final String code;
  final String name;
  final String currency;
  final String defaultLanguage;
  final String timezone;
  final List<String> supportedLanguages;
  final List<String> paymentProviders;
  final String phonePrefix;
  final double platformCommissionPercent;
  final bool mobileMoneyEnabled;

  const CountryConfig({
    required this.code,
    required this.name,
    required this.currency,
    required this.defaultLanguage,
    required this.timezone,
    required this.supportedLanguages,
    required this.paymentProviders,
    required this.phonePrefix,
    required this.platformCommissionPercent,
    required this.mobileMoneyEnabled,
  });
}
