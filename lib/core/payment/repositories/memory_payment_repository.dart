import '../models/payment.dart';
import '../models/payment_result.dart';
import 'payment_repository.dart';

class MemoryPaymentRepository implements PaymentRepository {
  final Map<String, Payment> _payments = {};

  @override
  Future<PaymentResult> create(Payment payment) async {
    _payments[payment.id] = payment;

    return PaymentResult(success: true, payment: payment);
  }

  @override
  Future<PaymentResult> update(Payment payment) async {
    _payments[payment.id] = payment;

    return PaymentResult(success: true, payment: payment);
  }

  @override
  Future<Payment?> findById(String paymentId) async {
    return _payments[paymentId];
  }

  @override
  Future<List<Payment>> findByConsultation(String consultationId) async {
    return _payments.values
        .where((payment) => payment.consultationId == consultationId)
        .toList();
  }

  @override
  Future<List<Payment>> findByPayer(String payerId) async {
    return _payments.values
        .where((payment) => payment.payerId == payerId)
        .toList();
  }

  @override
  Future<List<Payment>> findByReceiver(String receiverId) async {
    return _payments.values
        .where((payment) => payment.receiverId == receiverId)
        .toList();
  }
}
