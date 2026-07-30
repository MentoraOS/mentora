sealed class ExpertCatalogFailure implements Exception {
  const ExpertCatalogFailure();
}

final class ExpertCatalogInfrastructureFailure extends ExpertCatalogFailure {
  const ExpertCatalogInfrastructureFailure({required this.cause});

  final Object cause;
}
