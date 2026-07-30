import 'country_config.dart';

class CountryRegistry {
  CountryRegistry._();

  static const CountryConfig mali = CountryConfig(
    code: 'ML',
    name: 'Mali',
    currency: 'XOF',
    defaultLanguage: 'fr',
    timezone: 'Africa/Bamako',
    supportedLanguages: ['fr', 'bm'],
    paymentProviders: ['orange_money', 'wave', 'paydunya', 'cinetpay'],
    phonePrefix: '+223',
    platformCommissionPercent: 20,
    mobileMoneyEnabled: true,
  );

  static const CountryConfig senegal = CountryConfig(
    code: 'SN',
    name: 'Sénégal',
    currency: 'XOF',
    defaultLanguage: 'fr',
    timezone: 'Africa/Dakar',
    supportedLanguages: ['fr', 'wo'],
    paymentProviders: ['wave', 'orange_money', 'paydunya', 'cinetpay'],
    phonePrefix: '+221',
    platformCommissionPercent: 20,
    mobileMoneyEnabled: true,
  );

  static const CountryConfig ivoryCoast = CountryConfig(
    code: 'CI',
    name: 'Côte d’Ivoire',
    currency: 'XOF',
    defaultLanguage: 'fr',
    timezone: 'Africa/Abidjan',
    supportedLanguages: ['fr'],
    paymentProviders: ['orange_money', 'mtn_money', 'moov_money', 'cinetpay'],
    phonePrefix: '+225',
    platformCommissionPercent: 20,
    mobileMoneyEnabled: true,
  );

  static const List<CountryConfig> countries = [mali, senegal, ivoryCoast];
}
