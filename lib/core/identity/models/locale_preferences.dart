class LocalePreferences {
  final String languageCode;

  final String countryCode;

  final String timezone;

  final String currency;

  final bool use24HourFormat;

  final String dateFormat;

  const LocalePreferences({
    required this.languageCode,
    required this.countryCode,
    required this.timezone,
    required this.currency,
    required this.use24HourFormat,
    required this.dateFormat,
  });
}
