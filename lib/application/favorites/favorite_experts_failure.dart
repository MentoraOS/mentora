sealed class FavoriteExpertsFailure implements Exception {
  const FavoriteExpertsFailure();
}

final class FavoriteExpertsUnauthenticatedFailure
    extends FavoriteExpertsFailure {
  const FavoriteExpertsUnauthenticatedFailure();
}

final class FavoriteExpertsInfrastructureFailure
    extends FavoriteExpertsFailure {
  const FavoriteExpertsInfrastructureFailure({required this.cause});

  final Object cause;
}
