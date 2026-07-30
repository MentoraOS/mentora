import 'favorite_expert.dart';

abstract interface class FavoriteExpertsRepository {
  Stream<List<FavoriteExpert>> observeByUserId(String userId);

  Future<void> remove({required String userId, required String expertId});
}

final class FavoriteExpertsRepositoryException implements Exception {
  const FavoriteExpertsRepositoryException({required this.cause});

  final Object cause;
}
