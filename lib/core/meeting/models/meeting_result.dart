import 'meeting.dart';

class MeetingResult {
  final bool success;

  final String? message;

  final Meeting? meeting;

  const MeetingResult({required this.success, this.message, this.meeting});
}
