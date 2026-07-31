import '../../domain/expert_catalog/expert_catalog_entry.dart';
import '../../domain/expert_catalog/expert_catalog_repository.dart';
import 'expert_catalog_failure.dart';

final class ExpertCatalogApplicationService {
  const ExpertCatalogApplicationService({
    required ExpertCatalogRepository repository,
  }) : _repository = repository;

  final ExpertCatalogRepository _repository;

  /// The authoritative Catalog entry for [expertId], or `null` when absent.
  ///
  /// This is a Catalog lookup only: it does not validate reservation
  /// eligibility, interpret timezones, determine availability or evaluate
  /// conflict. Callers that need temporal truth pass the returned identity to
  /// Scheduling.
  Future<ExpertCatalogEntry?> findById(String expertId) async {
    try {
      return await _repository.findById(expertId);
    } on ExpertCatalogFailure {
      rethrow;
    } on ExpertCatalogRepositoryException catch (error) {
      throw ExpertCatalogInfrastructureFailure(cause: error.cause);
    } catch (error) {
      throw ExpertCatalogInfrastructureFailure(cause: error);
    }
  }

  Stream<List<ExpertCatalogEntry>> watchExperts() {
    return _repository.watchExperts().handleError((
      Object error,
      StackTrace stackTrace,
    ) {
      if (error is ExpertCatalogFailure) {
        Error.throwWithStackTrace(error, stackTrace);
      }

      if (error is ExpertCatalogRepositoryException) {
        Error.throwWithStackTrace(
          ExpertCatalogInfrastructureFailure(cause: error.cause),
          stackTrace,
        );
      }

      Error.throwWithStackTrace(
        ExpertCatalogInfrastructureFailure(cause: error),
        stackTrace,
      );
    });
  }
}
