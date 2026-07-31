import 'expert_catalog_entry.dart';

abstract interface class ExpertCatalogRepository {
  Stream<List<ExpertCatalogEntry>> watchExperts();

  /// The authoritative Catalog entry for [expertId], or `null` when no such
  /// expert exists.
  ///
  /// Returns Catalog truth only. It does not validate reservation
  /// eligibility, timezone support, availability or conflict. An
  /// infrastructure failure is reported as
  /// [ExpertCatalogRepositoryException] and MUST NOT be represented as an
  /// absent expert.
  Future<ExpertCatalogEntry?> findById(String expertId);
}

final class ExpertCatalogRepositoryException implements Exception {
  const ExpertCatalogRepositoryException({required this.cause});

  final Object cause;
}
