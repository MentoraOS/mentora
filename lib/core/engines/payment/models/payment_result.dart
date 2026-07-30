import 'payment_status.dart';

class PaymentResult {
  final PaymentStatus status;
  final String? transactionId;
  final String? providerReference;
  final String? message;
  final Map<String, dynamic>? rawResponse;

  const PaymentResult({
    required this.status,
    this.transactionId,
    this.providerReference,
    this.message,
    this.rawResponse,
  });

  bool get isSuccess => status == PaymentStatus.succeeded;
}
