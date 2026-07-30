import '../models/payment.dart';
import '../models/payment_result.dart';

abstract class PaymentRepository {
  Future<PaymentResult> create(Payment payment);

  Future<PaymentResult> update(Payment payment);

  Future<Payment?> findById(String paymentId);

  Future<List<Payment>> findByConsultation(String consultationId);

  Future<List<Payment>> findByPayer(String payerId);

  Future<List<Payment>> findByReceiver(String receiverId);
}
