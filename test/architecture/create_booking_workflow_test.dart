import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/booking/domains/booking_domain.dart';
import 'package:mentora/core/booking/engine/booking_engine.dart';
import 'package:mentora/core/booking/models/booking.dart';
import 'package:mentora/core/booking/models/booking_status.dart';
import 'package:mentora/core/booking/repositories/memory_booking_repository.dart';
import 'package:mentora/core/booking/workflows/create_booking_workflow.dart';

import 'package:mentora/core/workflow/workflow_context.dart';
import 'package:mentora/core/workflow/workflow_state.dart';

void main() {
  group('Create Booking Workflow', () {
    test('should create booking successfully', () async {
      final repository = MemoryBookingRepository();

      final domain = BookingDomain(repository: repository);

      final engine = BookingEngine(domain: domain);

      final booking = Booking(
        id: 'booking_workflow_001',
        consultationId: 'consultation_001',
        expertId: 'expert_001',
        clientId: 'client_001',
        startTimeUtc: DateTime.utc(2026, 7, 8, 10),
        endTimeUtc: DateTime.utc(2026, 7, 8, 10, 30),
        clientTimezone: 'Africa/Bamako',
        expertTimezone: 'Asia/Tokyo',
        status: BookingStatus.pending,
      );

      final workflow = CreateBookingWorkflow(engine: engine, booking: booking);

      final result = await workflow.execute(
        const WorkflowContext(
          userId: 'client_001',
          workspaceId: 'workspace_001',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.state, WorkflowState.completed);
      expect(result.data?.id, 'booking_workflow_001');
    });
  });
}
