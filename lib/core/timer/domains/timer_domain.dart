import '../models/timer_result.dart';
import '../models/timer_session.dart';
import '../models/timer_status.dart';
import '../repositories/timer_repository.dart';
import '../services/timer_state_machine.dart';

class TimerDomain {
  final TimerRepository repository;
  final TimerStateMachine stateMachine;

  const TimerDomain({
    required this.repository,
    this.stateMachine = const TimerStateMachine(),
  });

  bool _canMoveTo(TimerSession session, TimerStatus nextStatus) {
    return stateMachine.canTransition(from: session.status, to: nextStatus);
  }

  Future<TimerResult> create(TimerSession session) {
    return repository.create(session);
  }

  Future<TimerResult> start(TimerSession session) {
    if (!_canMoveTo(session, TimerStatus.running)) {
      return Future.value(
        TimerResult(
          success: false,
          message: 'Invalid timer transition',
          session: session,
        ),
      );
    }

    final started = TimerSession(
      id: session.id,
      consultationId: session.consultationId,
      totalDuration: session.totalDuration,
      elapsedDuration: session.elapsedDuration,
      startedAt: DateTime.now(),
      pausedAt: null,
      stoppedAt: null,
      status: TimerStatus.running,
    );

    return repository.update(started);
  }

  Future<TimerResult> pause(TimerSession session) {
    if (!_canMoveTo(session, TimerStatus.paused)) {
      return Future.value(
        TimerResult(
          success: false,
          message: 'Invalid timer transition',
          session: session,
        ),
      );
    }

    final now = DateTime.now();

    final elapsed = session.startedAt == null
        ? session.elapsedDuration
        : session.elapsedDuration + now.difference(session.startedAt!);

    final paused = TimerSession(
      id: session.id,
      consultationId: session.consultationId,
      totalDuration: session.totalDuration,
      elapsedDuration: elapsed,
      startedAt: null,
      pausedAt: now,
      stoppedAt: session.stoppedAt,
      status: TimerStatus.paused,
    );

    return repository.update(paused);
  }

  Future<TimerResult> resume(TimerSession session) {
    if (!_canMoveTo(session, TimerStatus.running)) {
      return Future.value(
        TimerResult(
          success: false,
          message: 'Invalid timer transition',
          session: session,
        ),
      );
    }

    final resumed = TimerSession(
      id: session.id,
      consultationId: session.consultationId,
      totalDuration: session.totalDuration,
      elapsedDuration: session.elapsedDuration,
      startedAt: DateTime.now(),
      pausedAt: null,
      stoppedAt: null,
      status: TimerStatus.running,
    );

    return repository.update(resumed);
  }

  Future<TimerResult> stop(TimerSession session) {
    if (!_canMoveTo(session, TimerStatus.stopped)) {
      return Future.value(
        TimerResult(
          success: false,
          message: 'Invalid timer transition',
          session: session,
        ),
      );
    }

    final now = DateTime.now();

    final elapsed = session.startedAt == null
        ? session.elapsedDuration
        : session.elapsedDuration + now.difference(session.startedAt!);

    final stopped = TimerSession(
      id: session.id,
      consultationId: session.consultationId,
      totalDuration: session.totalDuration,
      elapsedDuration: elapsed,
      startedAt: session.startedAt,
      pausedAt: session.pausedAt,
      stoppedAt: now,
      status: TimerStatus.stopped,
    );

    return repository.update(stopped);
  }
}
