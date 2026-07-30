import '../models/timer_result.dart';
import '../models/timer_session.dart';

abstract class TimerRepository {
  Future<TimerResult> create(TimerSession session);

  Future<TimerResult> update(TimerSession session);

  Future<TimerSession?> findById(String sessionId);

  Future<TimerSession?> findByConsultation(String consultationId);
}
