import '../../../../payment/engine/payment_engine.dart';
import '../../../../payment/models/payment.dart';
import '../../../../payment/models/payment_method.dart';
import '../../../../payment/models/payment_status.dart';

import '../../models/booking_execution_context.dart';
import '../phoenix_execution_step.dart';

class BookingPaymentStep extends PhoenixExecutionStep<BookingExecutionContext> {
  final PaymentEngine paymentEngine;

  const BookingPaymentStep({required this.paymentEngine});

  @override
  Future<BookingExecutionContext> execute(
    BookingExecutionContext context,
  ) async {
    final quote = context.pricingQuote;
    final payerId = context.event.userId;

    if (quote == null) {
      throw StateError('BookingPaymentStep requires a pricing quote');
    }

    if (payerId == null || payerId.isEmpty) {
      throw StateError('BookingPaymentStep requires a payerId');
    }

    final payment = Payment(
      id: 'payment_${context.event.id}',
      consultationId: quote.consultationId,
      payerId: payerId,
      receiverId: quote.expertId,
      amount: quote.total,
      currency: quote.currency,
      method: PaymentMethod.wallet,
      status: PaymentStatus.pending,
    );

    final createdResult = await paymentEngine.create(payment);

    if (!createdResult.success || createdResult.payment == null) {
      throw StateError(createdResult.message ?? 'Payment creation failed');
    }

    final authorizedResult = await paymentEngine.authorize(
      createdResult.payment!,
    );

    if (!authorizedResult.success || authorizedResult.payment == null) {
      throw StateError(
        authorizedResult.message ?? 'Payment authorization failed',
      );
    }

    return context.copyWith(paymentResult: authorizedResult);
  }
}
