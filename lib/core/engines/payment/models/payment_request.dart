import 'payment_provider_type.dart';

class PaymentRequest {
  final String bookingId;
  final String clientId;
  final String expertId;
  final int amount;
  final String currency;
  final String countryCode;
  final PaymentProviderType provider;
  final Map<String, dynamic>? metadata;

  const PaymentRequest({
    required this.bookingId,
    required this.clientId,
    required this.expertId,
    required this.amount,
    required this.currency,
    required this.countryCode,
    required this.provider,
    this.metadata,
  });
}
