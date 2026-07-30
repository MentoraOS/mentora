import 'booking_status.dart';

class Booking {
  final String id;
  final String consultationId;
  final String expertId;
  final String clientId;

  final DateTime startTimeUtc;
  final DateTime endTimeUtc;

  final String clientTimezone;
  final String expertTimezone;

  final BookingStatus status;

  const Booking({
    required this.id,
    required this.consultationId,
    required this.expertId,
    required this.clientId,
    required this.startTimeUtc,
    required this.endTimeUtc,
    required this.clientTimezone,
    required this.expertTimezone,
    this.status = BookingStatus.pending,
  });

  Duration get duration => endTimeUtc.difference(startTimeUtc);

  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isCancelled => status == BookingStatus.cancelled;
}
