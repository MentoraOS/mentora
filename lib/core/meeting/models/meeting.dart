import 'meeting_provider.dart';
import 'meeting_status.dart';

class Meeting {
  final String id;

  final String consultationId;

  final String roomId;

  final String hostToken;

  final String guestToken;

  final MeetingProvider provider;

  final MeetingStatus status;

  const Meeting({
    required this.id,
    required this.consultationId,
    required this.roomId,
    required this.hostToken,
    required this.guestToken,
    required this.provider,
    this.status = MeetingStatus.created,
  });
}
