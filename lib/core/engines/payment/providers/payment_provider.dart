import '../models/payment_request.dart';
import '../models/payment_result.dart';
import '../models/payment_provider_type.dart';

abstract class PaymentProvider {
  PaymentProviderType get type;

  Future<PaymentResult> startPayment(PaymentRequest request);

  Future<PaymentResult> verifyPayment(String transactionId);
}
