import '../models/meeting.dart';
import '../models/meeting_result.dart';
import 'meeting_repository.dart';

class MemoryMeetingRepository implements MeetingRepository {
  final Map<String, Meeting> _meetings = {};

  @override
  Future<MeetingResult> create(Meeting meeting) async {
    _meetings[meeting.id] = meeting;

    return MeetingResult(success: true, meeting: meeting);
  }

  @override
  Future<MeetingResult> update(Meeting meeting) async {
    _meetings[meeting.id] = meeting;

    return MeetingResult(success: true, meeting: meeting);
  }

  @override
  Future<Meeting?> findById(String meetingId) async {
    return _meetings[meetingId];
  }

  @override
  Future<List<Meeting>> findByConsultation(String consultationId) async {
    return _meetings.values
        .where((meeting) => meeting.consultationId == consultationId)
        .toList();
  }
}
