import '../../domain/expert_availability_exception/expert_availability_exception.dart';
import '../authentication/authentication_session.dart';
import 'expert_availability_exception_failure.dart';

/// Expert-side management of unavailability windows: create, list, delete.
///
/// The session expert only ever manages their own exceptions. The recurring
/// availability, the expert document and the C2/C3 engine are untouched —
/// exceptions live in their own collection and are applied as a display/
/// materialization filter by the booking funnel.
final class ExpertAvailabilityExceptionApplicationService {
  const ExpertAvailabilityExceptionApplicationService({
    required AuthenticationSession session,
    required ExpertAvailabilityExceptionRepository repository,
  }) : _session = session,
       _repository = repository;

  final AuthenticationSession _session;
  final ExpertAvailabilityExceptionRepository _repository;

  Future<void> create({
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    final expertId = _requireExpertId();

    // Reuse the domain validation without persisting the probe value.
    try {
      ExpertAvailabilityException(
        id: 'validation',
        expertId: expertId,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );
    } on ArgumentError catch (error) {
      throw ExpertAvailabilityExceptionInvalidFailure(cause: error);
    }

    return _translate(
      () => _repository.create(
        expertId: expertId,
        startDate: startDate,
        endDate: endDate,
        reason: reason.trim(),
      ),
    );
  }

  Future<List<ExpertAvailabilityException>> listMine() {
    final expertId = _requireExpertId();
    return _translate(() => _repository.listByExpertId(expertId));
  }

  Future<void> delete(String id) {
    final expertId = _requireExpertId();
    return _translate(() => _repository.delete(id: id, expertId: expertId));
  }

  String _requireExpertId() {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const ExpertAvailabilityExceptionUnauthenticatedFailure();
    }
    if (!_session.isExpert) {
      throw const ExpertAvailabilityExceptionForbiddenFailure();
    }
    return userId;
  }

  Future<T> _translate<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on ExpertAvailabilityExceptionNotFoundException {
      throw const ExpertAvailabilityExceptionNotFoundFailure();
    } on ExpertAvailabilityExceptionRepositoryException catch (error) {
      throw ExpertAvailabilityExceptionRepositoryFailure(cause: error.cause);
    } on ExpertAvailabilityExceptionFailure {
      rethrow;
    } catch (error) {
      throw ExpertAvailabilityExceptionRepositoryFailure(cause: error);
    }
  }
}
