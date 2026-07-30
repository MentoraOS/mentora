import '../models/payment_provider_type.dart';
import '../models/payment_request.dart';
import '../models/payment_result.dart';
import '../models/payment_status.dart';
import 'payment_provider.dart';

class MockPaymentProvider implements PaymentProvider {
  @override
  PaymentProviderType get type => PaymentProviderType.mock;

  @override
  Future<PaymentResult> startPayment(PaymentRequest request) async {
    await Future.delayed(const Duration(seconds: 2));

    return PaymentResult(
      status: PaymentStatus.succeeded,
      transactionId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      providerReference: request.bookingId,
      message: 'Paiement simulé avec succès',
      rawResponse: {
        'provider': 'mock',
        'amount': request.amount,
        'currency': request.currency,
        'countryCode': request.countryCode,
      },
    );
  }

  @override
  Future<PaymentResult> verifyPayment(String transactionId) async {
    return PaymentResult(
      status: PaymentStatus.succeeded,
      transactionId: transactionId,
      message: 'Paiement vérifié',
    );
  }
}
