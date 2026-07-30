import 'timer_status.dart';

class TimerSession {
  final String id;
  final String consultationId;

  final Duration totalDuration;
  final Duration elapsedDuration;

  final DateTime? startedAt;
  final DateTime? pausedAt;
  final DateTime? stoppedAt;

  final TimerStatus status;

  const TimerSession({
    required this.id,
    required this.consultationId,
    required this.totalDuration,
    this.elapsedDuration = Duration.zero,
    this.startedAt,
    this.pausedAt,
    this.stoppedAt,
    this.status = TimerStatus.idle,
  });

  Duration get remainingDuration {
    final remaining = totalDuration - elapsedDuration;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isStopped => status == TimerStatus.stopped;
  bool get isExpired =>
      status == TimerStatus.expired || remainingDuration == Duration.zero;
}
