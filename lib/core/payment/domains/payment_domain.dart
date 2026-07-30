import '../models/payment.dart';
import '../models/payment_result.dart';
import '../models/payment_status.dart';
import '../repositories/payment_repository.dart';
import '../services/payment_state_machine.dart';

class PaymentDomain {
  final PaymentRepository repository;
  final PaymentStateMachine stateMachine;

  const PaymentDomain({
    required this.repository,
    this.stateMachine = const PaymentStateMachine(),
  });

  Future<PaymentResult> create(Payment payment) {
    return repository.create(payment);
  }

  Future<Payment?> findById(String paymentId) {
    return repository.findById(paymentId);
  }

  Future<List<Payment>> findByConsultation(String consultationId) {
    return repository.findByConsultation(consultationId);
  }

  Future<PaymentResult> authorize(Payment payment) {
    return transitionTo(payment, PaymentStatus.authorized);
  }

  Future<PaymentResult> moveToEscrow(Payment payment) {
    return transitionTo(payment, PaymentStatus.escrow);
  }

  Future<PaymentResult> capture(Payment payment) {
    return transitionTo(payment, PaymentStatus.captured);
  }

  Future<PaymentResult> release(Payment payment) {
    return transitionTo(payment, PaymentStatus.released);
  }

  Future<PaymentResult> refund(Payment payment) {
    return transitionTo(payment, PaymentStatus.refunded);
  }

  Future<PaymentResult> fail(Payment payment) {
    return transitionTo(payment, PaymentStatus.failed);
  }

  Future<PaymentResult> cancel(Payment payment) {
    return transitionTo(payment, PaymentStatus.cancelled);
  }

  Future<PaymentResult> transitionTo(
    Payment payment,
    PaymentStatus nextStatus,
  ) {
    final canMove = stateMachine.canTransition(
      from: payment.status,
      to: nextStatus,
    );

    if (!canMove) {
      return Future.value(
        PaymentResult(
          success: false,
          message: 'Invalid payment transition',
          payment: payment,
        ),
      );
    }

    return repository.update(payment.copyWith(status: nextStatus));
  }
}
