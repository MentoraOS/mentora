import '../../../pricing/models/pricing_quote.dart';
import 'phoenix_execution_context.dart';
import '../../../events/models/phoenix_event.dart';
import '../../../payment/models/payment_result.dart';

class BookingExecutionContext extends PhoenixExecutionContext {
  final PricingQuote? pricingQuote;
  final PaymentResult? paymentResult;

  const BookingExecutionContext({
    required super.event,
    this.pricingQuote,
    this.paymentResult,
  });
  @override
  BookingExecutionContext copyWith({
    PhoenixEvent? event,
    PricingQuote? pricingQuote,
    PaymentResult? paymentResult,
  }) {
    return BookingExecutionContext(
      event: event ?? this.event,
      pricingQuote: pricingQuote ?? this.pricingQuote,
      paymentResult: paymentResult ?? this.paymentResult,
    );
  }
}
