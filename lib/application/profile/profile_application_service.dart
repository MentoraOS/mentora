import '../../domain/profile/profile.dart';
import '../../domain/profile/profile_repository.dart';
import '../authentication/authentication_session.dart';
import 'profile_failure.dart';

final class ProfileApplicationService {
  const ProfileApplicationService({
    required AuthenticationSession session,
    required ProfileRepository repository,
  }) : _session = session,
       _repository = repository;

  final AuthenticationSession _session;
  final ProfileRepository _repository;

  Future<Profile> getCurrentProfile() async {
    final userId = _requireCurrentUserId();

    try {
      final profile = await _repository.findByUserId(userId);

      if (profile == null) {
        throw const ProfileNotFoundFailure();
      }

      return profile;
    } on ProfileFailure {
      rethrow;
    } on ProfileRepositoryException catch (error) {
      throw ProfileInfrastructureFailure(cause: error.cause);
    }
  }

  Stream<Profile> observeCurrentProfile() {
    final userId = _requireCurrentUserId();

    return _repository
        .observeByUserId(userId)
        .handleError((Object error, StackTrace stackTrace) {
          if (error is ProfileFailure) {
            Error.throwWithStackTrace(error, stackTrace);
          }

          if (error is ProfileRepositoryException) {
            Error.throwWithStackTrace(
              ProfileInfrastructureFailure(cause: error.cause),
              stackTrace,
            );
          }

          Error.throwWithStackTrace(
            ProfileInfrastructureFailure(cause: error),
            stackTrace,
          );
        })
        .map((profile) {
          if (profile == null) {
            throw const ProfileNotFoundFailure();
          }

          return profile;
        });
  }

  Future<void> updateCurrentProfile({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final userId = _requireCurrentUserId();

    try {
      await _repository.update(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
    } on ProfileRepositoryException catch (error) {
      throw ProfileInfrastructureFailure(cause: error.cause);
    } catch (error) {
      if (error is ProfileFailure) {
        rethrow;
      }

      throw ProfileInfrastructureFailure(cause: error);
    }
  }

  String _requireCurrentUserId() {
    final userId = _session.currentUserId?.trim();

    if (userId == null || userId.isEmpty) {
      throw const ProfileUnauthenticatedFailure();
    }

    return userId;
  }
}
