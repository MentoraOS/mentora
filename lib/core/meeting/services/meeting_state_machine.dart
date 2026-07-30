import '../models/meeting_status.dart';

class MeetingStateMachine {
  const MeetingStateMachine();

  bool canTransition({required MeetingStatus from, required MeetingStatus to}) {
    return allowedTransitions[from]?.contains(to) ?? false;
  }

  static const Map<MeetingStatus, List<MeetingStatus>> allowedTransitions = {
    MeetingStatus.created: [MeetingStatus.waiting, MeetingStatus.cancelled],

    MeetingStatus.waiting: [MeetingStatus.live, MeetingStatus.cancelled],

    MeetingStatus.live: [MeetingStatus.paused, MeetingStatus.ended],

    MeetingStatus.paused: [
      MeetingStatus.live,
      MeetingStatus.ended,
      MeetingStatus.cancelled,
    ],

    MeetingStatus.ended: [],

    MeetingStatus.cancelled: [],
  };
}
