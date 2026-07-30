import '../../domain/favorites/favorite_expert.dart';
import '../../domain/favorites/favorite_experts_repository.dart';
import '../authentication/authentication_session.dart';
import 'favorite_experts_failure.dart';

final class FavoriteExpertsApplicationService {
  const FavoriteExpertsApplicationService({
    required AuthenticationSession session,
    required FavoriteExpertsRepository repository,
  }) : _session = session,
       _repository = repository;

  final AuthenticationSession _session;
  final FavoriteExpertsRepository _repository;

  Stream<List<FavoriteExpert>> observeCurrentFavorites() {
    final userId = _requireCurrentUserId();

    return _repository.observeByUserId(userId).handleError((
      Object error,
      StackTrace stackTrace,
    ) {
      if (error is FavoriteExpertsFailure) {
        Error.throwWithStackTrace(error, stackTrace);
      }

      if (error is FavoriteExpertsRepositoryException) {
        Error.throwWithStackTrace(
          FavoriteExpertsInfrastructureFailure(cause: error.cause),
          stackTrace,
        );
      }

      Error.throwWithStackTrace(
        FavoriteExpertsInfrastructureFailure(cause: error),
        stackTrace,
      );
    });
  }

  Future<void> removeCurrentFavorite(String expertId) async {
    final userId = _requireCurrentUserId();

    try {
      await _repository.remove(userId: userId, expertId: expertId);
    } on FavoriteExpertsRepositoryException catch (error) {
      throw FavoriteExpertsInfrastructureFailure(cause: error.cause);
    } catch (error) {
      if (error is FavoriteExpertsFailure) {
        rethrow;
      }

      throw FavoriteExpertsInfrastructureFailure(cause: error);
    }
  }

  String _requireCurrentUserId() {
    final userId = _session.currentUserId?.trim();

    if (userId == null || userId.isEmpty) {
      throw const FavoriteExpertsUnauthenticatedFailure();
    }

    return userId;
  }
}
