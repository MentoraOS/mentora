import '../../domain/expert_catalog/expert_catalog_entry.dart';
import '../../domain/expert_catalog/expert_catalog_repository.dart';
import 'expert_catalog_failure.dart';

final class ExpertCatalogApplicationService {
  const ExpertCatalogApplicationService({
    required ExpertCatalogRepository repository,
  }) : _repository = repository;

  final ExpertCatalogRepository _repository;

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
