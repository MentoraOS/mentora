import 'session_model.dart';

abstract interface class SessionRepository {
  Future<SessionModel?> fetchCurrentSession();

  Future<void> signOut();
}
