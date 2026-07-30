import '../../../events/models/phoenix_event.dart';
import '../models/orchestration_result.dart';
import 'orchestration_rule.dart';
import '../services/booking_orchestration_service.dart';

class BookingConfirmedRule extends OrchestrationRule {
  final BookingOrchestrationService service;

  BookingConfirmedRule({required this.service});

  @override
  bool supports(PhoenixEvent event) {
    return event.name == 'booking.confirmed';
  }

  @override
  Future<OrchestrationResult> execute(PhoenixEvent event) {
    return service.handleBookingConfirmed(event);
  }
}
