import 'payment_method.dart';
import 'payment_status.dart';

class Payment {
  final String id;
  final String consultationId;
  final String payerId;
  final String receiverId;

  final double amount;
  final String currency;

  final PaymentMethod method;
  final PaymentStatus status;

  const Payment({
    required this.id,
    required this.consultationId,
    required this.payerId,
    required this.receiverId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
  });

  Payment copyWith({PaymentStatus? status}) {
    return Payment(
      id: id,
      consultationId: consultationId,
      payerId: payerId,
      receiverId: receiverId,
      amount: amount,
      currency: currency,
      method: method,
      status: status ?? this.status,
    );
  }
}
