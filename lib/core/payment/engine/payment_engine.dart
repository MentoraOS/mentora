import '../domains/payment_domain.dart';
import '../models/payment.dart';
import '../models/payment_result.dart';

class PaymentEngine {
  final PaymentDomain domain;

  const PaymentEngine({required this.domain});

  Future<PaymentResult> create(Payment payment) {
    return domain.create(payment);
  }

  Future<PaymentResult> authorize(Payment payment) {
    return domain.authorize(payment);
  }

  Future<PaymentResult> moveToEscrow(Payment payment) {
    return domain.moveToEscrow(payment);
  }

  Future<PaymentResult> capture(Payment payment) {
    return domain.capture(payment);
  }

  Future<PaymentResult> release(Payment payment) {
    return domain.release(payment);
  }

  Future<PaymentResult> refund(Payment payment) {
    return domain.refund(payment);
  }

  Future<PaymentResult> fail(Payment payment) {
    return domain.fail(payment);
  }

  Future<PaymentResult> cancel(Payment payment) {
    return domain.cancel(payment);
  }

  Future<Payment?> findById(String paymentId) {
    return domain.findById(paymentId);
  }

  Future<List<Payment>> findByConsultation(String consultationId) {
    return domain.findByConsultation(consultationId);
  }
}
