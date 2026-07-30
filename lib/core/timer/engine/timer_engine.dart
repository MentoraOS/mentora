import '../domains/timer_domain.dart';
import '../models/timer_result.dart';
import '../models/timer_session.dart';

class TimerEngine {
  final TimerDomain domain;

  const TimerEngine({required this.domain});

  Future<TimerResult> create(TimerSession session) {
    return domain.create(session);
  }

  Future<TimerResult> start(TimerSession session) {
    return domain.start(session);
  }

  Future<TimerResult> pause(TimerSession session) {
    return domain.pause(session);
  }

  Future<TimerResult> resume(TimerSession session) {
    return domain.resume(session);
  }

  Future<TimerResult> stop(TimerSession session) {
    return domain.stop(session);
  }
}
