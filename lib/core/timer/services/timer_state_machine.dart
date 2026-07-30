import '../models/timer_status.dart';

class TimerStateMachine {
  const TimerStateMachine();

  bool canTransition({required TimerStatus from, required TimerStatus to}) {
    return allowedTransitions[from]?.contains(to) ?? false;
  }

  static const Map<TimerStatus, List<TimerStatus>> allowedTransitions = {
    TimerStatus.idle: [TimerStatus.running, TimerStatus.stopped],

    TimerStatus.running: [
      TimerStatus.paused,
      TimerStatus.stopped,
      TimerStatus.expired,
    ],

    TimerStatus.paused: [
      TimerStatus.running,
      TimerStatus.stopped,
      TimerStatus.expired,
    ],

    TimerStatus.stopped: [],

    TimerStatus.expired: [],
  };
}
