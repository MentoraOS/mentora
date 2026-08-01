import '../../domain/consultation_brief/consultation_brief.dart';
import '../authentication/authentication_session.dart';
import 'consultation_brief_failure.dart';

/// Saves and reads the client's consultation brief.
///
/// A plain persistent snapshot keyed by the booking identity: no AI, no
/// summary, no workflow. Saving fails closed when the booking does not exist
/// for the session client.
final class ConsultationBriefApplicationService {
  const ConsultationBriefApplicationService({
    required AuthenticationSession session,
    required ConsultationBriefRepository repository,
  }) : _session = session,
       _repository = repository;

  final AuthenticationSession _session;
  final ConsultationBriefRepository _repository;

  Future<void> save({
    required String bookingId,
    required String objective,
    required String description,
    required String questions,
    required String expectedOutcome,
  }) async {
    final clientId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || clientId == null || clientId.isEmpty) {
      throw const ConsultationBriefUnauthenticatedFailure();
    }

    final ConsultationBrief brief;
    try {
      brief = ConsultationBrief(
        objective: objective,
        description: description,
        questions: questions,
        expectedOutcome: expectedOutcome,
      );
    } on ArgumentError catch (error) {
      throw ConsultationBriefInvalidFailure(cause: error);
    }

    try {
      await _repository.save(
        bookingId: bookingId,
        clientId: clientId,
        brief: brief,
      );
    } on ConsultationBriefBookingNotFoundException {
      throw const ConsultationBriefBookingNotFoundFailure();
    } on ConsultationBriefRepositoryException catch (error) {
      throw ConsultationBriefRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw ConsultationBriefRepositoryFailure(cause: error);
    }
  }

  Future<ConsultationBrief?> loadByBookingId(String bookingId) async {
    try {
      return await _repository.loadByBookingId(bookingId);
    } on ConsultationBriefRepositoryException catch (error) {
      throw ConsultationBriefRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw ConsultationBriefRepositoryFailure(cause: error);
    }
  }
}
