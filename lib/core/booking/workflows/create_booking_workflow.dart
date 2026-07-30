import '../../workflow/workflow.dart';
import '../../workflow/workflow_context.dart';
import '../../workflow/workflow_result.dart';

import '../engine/booking_engine.dart';
import '../models/booking.dart';

class CreateBookingWorkflow extends Workflow<Booking> {
  final BookingEngine engine;
  final Booking booking;

  const CreateBookingWorkflow({required this.engine, required this.booking});

  @override
  String get name => 'booking.create';

  @override
  Future<WorkflowResult<Booking>> execute(WorkflowContext context) async {
    final result = await engine.create(booking);

    if (!result.success || result.booking == null) {
      return WorkflowResult.failure(
        message: result.message ?? 'Booking creation failed',
      );
    }

    return WorkflowResult.success(
      data: result.booking,
      message: 'Booking created successfully',
    );
  }
}
