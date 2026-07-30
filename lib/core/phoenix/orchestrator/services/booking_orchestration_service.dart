import '../../../events/models/phoenix_event.dart';
import '../models/orchestration_result.dart';
import '../registry/pipeline_registry.dart';
import '../models/booking_execution_context.dart';
import '../execution/phoenix_execution_engine.dart';

class BookingOrchestrationService {
  final PipelineRegistry pipelineRegistry;

  const BookingOrchestrationService({required this.pipelineRegistry});

  Future<OrchestrationResult> handleBookingConfirmed(PhoenixEvent event) async {
    final bookingId = event.payload['bookingId'];
    final expertId = event.payload['expertId'];
    final userId = event.userId;
    final consultationId = event.consultationId;

    if (bookingId == null ||
        expertId == null ||
        userId == null ||
        consultationId == null) {
      return const OrchestrationResult(
        success: false,
        message: 'Missing booking orchestration payload',
      );
    }

    final initialContext = BookingExecutionContext(event: event);

    final pipeline = pipelineRegistry.resolve<BookingExecutionContext>(
      event.name,
    );

    const executionEngine = PhoenixExecutionEngine<BookingExecutionContext>();

    final context = await executionEngine.execute(pipeline, initialContext);

    return OrchestrationResult(
      success: true,
      message:
          'Booking orchestration completed (${context.pricingQuote!.total})',
    );
  }
}
