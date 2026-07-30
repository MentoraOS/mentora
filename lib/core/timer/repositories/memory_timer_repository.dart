import '../models/timer_result.dart';
import '../models/timer_session.dart';
import 'timer_repository.dart';

class MemoryTimerRepository implements TimerRepository {
  final Map<String, TimerSession> _sessions = {};

  @override
  Future<TimerResult> create(TimerSession session) async {
    _sessions[session.id] = session;

    return TimerResult(success: true, session: session);
  }

  @override
  Future<TimerResult> update(TimerSession session) async {
    _sessions[session.id] = session;

    return TimerResult(success: true, session: session);
  }

  @override
  Future<TimerSession?> findById(String sessionId) async {
    return _sessions[sessionId];
  }

  @override
  Future<TimerSession?> findByConsultation(String consultationId) async {
    for (final session in _sessions.values) {
      if (session.consultationId == consultationId) {
        return session;
      }
    }

    return null;
  }
}
