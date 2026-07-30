import '../models/session.dart';

class SessionDomain {
  Session? _currentSession;

  Session? get currentSession => _currentSession;

  bool get hasSession => _currentSession != null;

  bool get isSessionValid => _currentSession?.isValid ?? false;

  bool get isSessionExpired => _currentSession?.isExpired ?? false;

  void start(Session session) {
    _currentSession = session;
  }

  void end() {
    _currentSession = null;
  }

  void refreshActivity() {
    final session = _currentSession;

    if (session == null) return;

    _currentSession = Session(
      id: session.id,
      identity: session.identity,
      startedAt: session.startedAt,
      expiresAt: session.expiresAt,
      lastActivityAt: DateTime.now(),
      active: session.active,
    );
  }
}
