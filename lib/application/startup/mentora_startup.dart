import '../authentication/authentication_session.dart';
import 'startup_result.dart';

final class MentoraStartup {
  const MentoraStartup({required AuthenticationSession session})
    : _session = session;

  final AuthenticationSession _session;

  Future<StartupResult> execute() async {
    try {
      await _session.initialize();

      if (!_session.isAuthenticated) {
        return const StartupResult.unauthenticated();
      }

      return const StartupResult.ready();
    } catch (error, stackTrace) {
      return StartupResult.failure(error: error, stackTrace: stackTrace);
    }
  }
}
