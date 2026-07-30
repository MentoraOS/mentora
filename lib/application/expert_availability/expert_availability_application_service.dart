import '../../domain/expert_availability/expert_availability.dart';
import '../../domain/expert_availability/expert_availability_repository.dart';
import '../authentication/authentication_session.dart';
import 'expert_availability_failure.dart';

final class ExpertAvailabilityApplicationService {
  const ExpertAvailabilityApplicationService({
    required AuthenticationSession session,
    required ExpertAvailabilityRepository repository,
  }) : _session = session,
       _repository = repository;

  final AuthenticationSession _session;
  final ExpertAvailabilityRepository _repository;

  Future<ExpertAvailability> loadCurrentAvailability() {
    final expertId = _requireCurrentExpertId();
    return _translate(() => _repository.loadByExpertId(expertId));
  }

  Future<ExpertAvailability> saveCurrentAvailability(
    ExpertAvailability availability,
  ) {
    final expertId = _requireCurrentExpertId();
    return _translate(
      () => _repository.saveByExpertId(
        expertId: expertId,
        availability: availability,
      ),
    );
  }

  String _requireCurrentExpertId() {
    final expertId = _session.currentUserId?.trim();

    if (!_session.isAuthenticated || expertId == null || expertId.isEmpty) {
      throw const ExpertAvailabilityUnauthenticatedFailure();
    }

    if (!_session.isExpert) {
      throw const ExpertAvailabilityForbiddenFailure();
    }

    return expertId;
  }

  Future<ExpertAvailability> _translate(
    Future<ExpertAvailability> Function() operation,
  ) async {
    try {
      return await operation();
    } on ExpertAvailabilityConcurrencyException catch (error) {
      throw ExpertAvailabilityConcurrencyConflictFailure(
        expectedRevision: error.expectedRevision,
        actualRevision: error.actualRevision,
      );
    } on ExpertAvailabilityRepositoryException catch (error) {
      if (error.malformedData) {
        throw ExpertAvailabilityMalformedDataFailure(cause: error.cause);
      }
      throw ExpertAvailabilityRepositoryFailure(cause: error.cause);
    } on ExpertAvailabilityFailure {
      rethrow;
    } catch (error) {
      throw ExpertAvailabilityRepositoryFailure(cause: error);
    }
  }
}
