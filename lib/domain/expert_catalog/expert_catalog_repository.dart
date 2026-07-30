import 'expert_catalog_entry.dart';

abstract interface class ExpertCatalogRepository {
  Stream<List<ExpertCatalogEntry>> watchExperts();
}

final class ExpertCatalogRepositoryException implements Exception {
  const ExpertCatalogRepositoryException({required this.cause});

  final Object cause;
}
