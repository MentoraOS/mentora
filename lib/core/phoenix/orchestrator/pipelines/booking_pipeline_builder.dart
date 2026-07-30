import 'package:mentora/core/phoenix/orchestrator/execution/execution_pipeline.dart';
import '../../../payment/engine/payment_engine.dart';
import '../../../pricing/engine/pricing_engine.dart';
import '../execution/steps/booking_payment_step.dart';
import '../steps/booking_pricing_step.dart';
import '../models/booking_execution_context.dart';

class BookingPipelineBuilder {
  final PricingEngine pricingEngine;
  final PaymentEngine paymentEngine;

  const BookingPipelineBuilder({
    required this.pricingEngine,
    required this.paymentEngine,
  });

  ExecutionPipeline<BookingExecutionContext> build() {
    return ExecutionPipeline<BookingExecutionContext>(
      steps: [
        BookingPricingStep(pricingEngine: pricingEngine),
        BookingPaymentStep(paymentEngine: paymentEngine),
      ],
    );
  }
}
