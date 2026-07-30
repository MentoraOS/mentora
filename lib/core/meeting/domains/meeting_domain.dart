import '../models/meeting.dart';
import '../models/meeting_result.dart';
import '../models/meeting_status.dart';
import '../repositories/meeting_repository.dart';
import '../services/meeting_state_machine.dart';

class MeetingDomain {
  final MeetingRepository repository;
  final MeetingStateMachine stateMachine;

  const MeetingDomain({
    required this.repository,
    this.stateMachine = const MeetingStateMachine(),
  });

  Future<MeetingResult> create(Meeting meeting) {
    return repository.create(meeting);
  }

  Future<Meeting?> findById(String meetingId) {
    return repository.findById(meetingId);
  }

  Future<List<Meeting>> findByConsultation(String consultationId) {
    return repository.findByConsultation(consultationId);
  }

  Future<MeetingResult> start(Meeting meeting) {
    return _changeStatus(meeting, MeetingStatus.live);
  }

  Future<MeetingResult> pause(Meeting meeting) {
    return _changeStatus(meeting, MeetingStatus.paused);
  }

  Future<MeetingResult> end(Meeting meeting) {
    return _changeStatus(meeting, MeetingStatus.ended);
  }

  Future<MeetingResult> cancel(Meeting meeting) {
    return _changeStatus(meeting, MeetingStatus.cancelled);
  }

  Future<MeetingResult> _changeStatus(Meeting meeting, MeetingStatus status) {
    final canMove = stateMachine.canTransition(
      from: meeting.status,
      to: status,
    );

    if (!canMove) {
      return Future.value(
        MeetingResult(
          success: false,
          message: 'Invalid meeting transition',
          meeting: meeting,
        ),
      );
    }

    final updated = Meeting(
      id: meeting.id,
      consultationId: meeting.consultationId,
      roomId: meeting.roomId,
      hostToken: meeting.hostToken,
      guestToken: meeting.guestToken,
      provider: meeting.provider,
      status: status,
    );

    return repository.update(updated);
  }
}
