import 'timer_session.dart';

class TimerResult {
  final bool success;
  final String? message;
  final TimerSession? session;

  const TimerResult({required this.success, this.message, this.session});
}
