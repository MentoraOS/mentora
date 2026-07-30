import 'country_config.dart';
import 'country_registry.dart';

class CountryEngine {
  CountryEngine._();

  static CountryConfig getByCode(String? countryCode) {
    return CountryRegistry.countries.firstWhere(
      (country) => country.code == countryCode,
      orElse: () => CountryRegistry.mali,
    );
  }

  static String currencyOf(String? countryCode) {
    return getByCode(countryCode).currency;
  }

  static String defaultLanguageOf(String? countryCode) {
    return getByCode(countryCode).defaultLanguage;
  }

  static String timezoneOf(String? countryCode) {
    return getByCode(countryCode).timezone;
  }

  static List<String> paymentProvidersOf(String? countryCode) {
    return getByCode(countryCode).paymentProviders;
  }

  static bool supportsPaymentProvider(String? countryCode, String provider) {
    return getByCode(countryCode).paymentProviders.contains(provider);
  }

  static bool supportsLanguage(String? countryCode, String language) {
    return getByCode(countryCode).supportedLanguages.contains(language);
  }

  static double commissionOf(String? countryCode) {
    return getByCode(countryCode).platformCommissionPercent;
  }

  static bool mobileMoneyEnabled(String? countryCode) {
    return getByCode(countryCode).mobileMoneyEnabled;
  }
}
