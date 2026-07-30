import 'payment.dart';

class PaymentResult {
  final bool success;
  final String? message;
  final Payment? payment;

  const PaymentResult({required this.success, this.message, this.payment});
}
