import '../domains/meeting_domain.dart';
import '../models/meeting.dart';
import '../models/meeting_result.dart';

class MeetingEngine {
  final MeetingDomain domain;

  const MeetingEngine({required this.domain});

  Future<MeetingResult> create(Meeting meeting) {
    return domain.create(meeting);
  }

  Future<MeetingResult> start(Meeting meeting) {
    return domain.start(meeting);
  }

  Future<MeetingResult> pause(Meeting meeting) {
    return domain.pause(meeting);
  }

  Future<MeetingResult> end(Meeting meeting) {
    return domain.end(meeting);
  }

  Future<MeetingResult> cancel(Meeting meeting) {
    return domain.cancel(meeting);
  }

  Future<Meeting?> findById(String meetingId) {
    return domain.findById(meetingId);
  }

  Future<List<Meeting>> findByConsultation(String consultationId) {
    return domain.findByConsultation(consultationId);
  }
}
