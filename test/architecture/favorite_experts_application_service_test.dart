import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/favorites/favorite_experts_application_service.dart';
import 'package:mentora/application/favorites/favorite_experts_failure.dart';
import 'package:mentora/domain/favorites/favorite_expert.dart';
import 'package:mentora/domain/favorites/favorite_experts_repository.dart';

void main() {
  group('FavoriteExpertsApplicationService', () {
    test('observes favorites for the authenticated current user', () async {
      final repository = _FakeFavoriteExpertsRepository(
        favorites: const [
          FavoriteExpert(
            id: 'expert_1',
            name: 'Awa',
            title: 'Coach',
            country: 'ML',
            rating: '4.9',
            price: '500 FCFA/min',
          ),
        ],
      );
      final service = FavoriteExpertsApplicationService(
        session: _FakeAuthenticationSession('user_1'),
        repository: repository,
      );

      final favorites = await service.observeCurrentFavorites().first;

      expect(favorites.single.id, 'expert_1');
      expect(repository.lastObservedUserId, 'user_1');
    });

    test('rejects observation without an authenticated user', () {
      final service = FavoriteExpertsApplicationService(
        session: _FakeAuthenticationSession(null),
        repository: _FakeFavoriteExpertsRepository(),
      );

      expect(
        service.observeCurrentFavorites,
        throwsA(isA<FavoriteExpertsUnauthenticatedFailure>()),
      );
    });

    test('removes a favorite for the authenticated current user', () async {
      final repository = _FakeFavoriteExpertsRepository();
      final service = FavoriteExpertsApplicationService(
        session: _FakeAuthenticationSession('user_1'),
        repository: repository,
      );

      await service.removeCurrentFavorite('expert_1');

      expect(repository.lastRemovedUserId, 'user_1');
      expect(repository.lastRemovedExpertId, 'expert_1');
    });

    test('rejects removal without an authenticated user', () {
      final service = FavoriteExpertsApplicationService(
        session: _FakeAuthenticationSession(null),
        repository: _FakeFavoriteExpertsRepository(),
      );

      expect(
        () => service.removeCurrentFavorite('expert_1'),
        throwsA(isA<FavoriteExpertsUnauthenticatedFailure>()),
      );
    });

    test('maps observation repository failures', () async {
      final cause = StateError('offline');
      final service = FavoriteExpertsApplicationService(
        session: _FakeAuthenticationSession('user_1'),
        repository: _FakeFavoriteExpertsRepository(error: cause),
      );

      await expectLater(
        service.observeCurrentFavorites(),
        emitsError(
          isA<FavoriteExpertsInfrastructureFailure>().having(
            (failure) => failure.cause,
            'cause',
            cause,
          ),
        ),
      );
    });

    test('maps removal repository failures', () async {
      final cause = StateError('offline');
      final service = FavoriteExpertsApplicationService(
        session: _FakeAuthenticationSession('user_1'),
        repository: _FakeFavoriteExpertsRepository(error: cause),
      );

      await expectLater(
        service.removeCurrentFavorite('expert_1'),
        throwsA(
          isA<FavoriteExpertsInfrastructureFailure>().having(
            (failure) => failure.cause,
            'cause',
            cause,
          ),
        ),
      );
    });
  });
}

final class _FakeFavoriteExpertsRepository
    implements FavoriteExpertsRepository {
  _FakeFavoriteExpertsRepository({this.favorites = const [], this.error});

  final List<FavoriteExpert> favorites;
  final Object? error;
  String? lastObservedUserId;
  String? lastRemovedUserId;
  String? lastRemovedExpertId;

  @override
  Stream<List<FavoriteExpert>> observeByUserId(String userId) {
    lastObservedUserId = userId;
    if (error case final error?) {
      return Stream.error(FavoriteExpertsRepositoryException(cause: error));
    }
    return Stream.value(favorites);
  }

  @override
  Future<void> remove({
    required String userId,
    required String expertId,
  }) async {
    lastRemovedUserId = userId;
    lastRemovedExpertId = expertId;
    if (error case final error?) {
      throw FavoriteExpertsRepositoryException(cause: error);
    }
  }
}

final class _FakeAuthenticationSession extends Fake
    implements AuthenticationSession {
  _FakeAuthenticationSession(this.currentUserId);

  @override
  final String? currentUserId;
}
