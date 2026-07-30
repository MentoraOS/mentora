import '../models/meeting.dart';
import '../models/meeting_result.dart';

abstract class MeetingRepository {
  Future<MeetingResult> create(Meeting meeting);

  Future<MeetingResult> update(Meeting meeting);

  Future<Meeting?> findById(String meetingId);

  Future<List<Meeting>> findByConsultation(String consultationId);
}
