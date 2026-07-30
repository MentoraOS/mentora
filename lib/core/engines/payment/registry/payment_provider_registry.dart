import '../models/payment_provider_type.dart';
import '../providers/payment_provider.dart';

class PaymentProviderRegistry {
  PaymentProviderRegistry._();

  static final Map<PaymentProviderType, PaymentProvider> _providers = {};

  static PaymentProvider? providerOf(PaymentProviderType type) {
    return _providers[type];
  }

  static void register(PaymentProvider provider) {
    _providers[provider.type] = provider;
  }

  static List<PaymentProviderType> availableProviders() {
    return _providers.keys.toList();
  }
}
