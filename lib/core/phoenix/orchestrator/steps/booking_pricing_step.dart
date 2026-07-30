import '../../../pricing/engine/pricing_engine.dart';
import '../../../pricing/models/pricing_plan.dart';
import '../../../pricing/models/pricing_type.dart';

import '../execution/phoenix_execution_step.dart';
import '../models/booking_execution_context.dart';

class BookingPricingStep extends PhoenixExecutionStep<BookingExecutionContext> {
  final PricingEngine pricingEngine;

  const BookingPricingStep({required this.pricingEngine});

  @override
  Future<BookingExecutionContext> execute(
    BookingExecutionContext context,
  ) async {
    final event = context.event;

    final bookingId = event.payload['bookingId'];
    final expertId = event.payload['expertId'];
    final consultationId = event.consultationId;

    final pricingResult = pricingEngine.quote(
      quoteId: 'quote_$bookingId',
      consultationId: consultationId!,
      plan: PricingPlan(
        id: 'plan_$expertId',
        expertId: expertId,
        type: PricingType.perMinute,
        currency: 'USD',
        amount: 2,
      ),
      duration: const Duration(minutes: 30),
    );

    if (!pricingResult.success || pricingResult.quote == null) {
      throw Exception('Pricing step failed');
    }

    return context.copyWith(pricingQuote: pricingResult.quote);
  }
}
