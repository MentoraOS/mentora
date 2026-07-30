import '../models/payment_status.dart';

class PaymentStateMachine {
  const PaymentStateMachine();

  bool canTransition({required PaymentStatus from, required PaymentStatus to}) {
    return allowedTransitions[from]?.contains(to) ?? false;
  }

  static const Map<PaymentStatus, List<PaymentStatus>> allowedTransitions = {
    PaymentStatus.pending: [
      PaymentStatus.authorized,
      PaymentStatus.failed,
      PaymentStatus.cancelled,
    ],

    PaymentStatus.authorized: [
      PaymentStatus.escrow,
      PaymentStatus.captured,
      PaymentStatus.failed,
      PaymentStatus.cancelled,
    ],

    PaymentStatus.escrow: [
      PaymentStatus.captured,
      PaymentStatus.released,
      PaymentStatus.refunded,
      PaymentStatus.failed,
    ],

    PaymentStatus.captured: [
      PaymentStatus.released,
      PaymentStatus.refunded,
      PaymentStatus.failed,
    ],

    PaymentStatus.released: [],

    PaymentStatus.refunded: [],

    PaymentStatus.failed: [],

    PaymentStatus.cancelled: [],
  };
}
