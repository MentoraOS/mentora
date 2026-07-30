import 'expert_availability.dart';

abstract interface class ExpertAvailabilityRepository {
  Future<ExpertAvailability> loadByExpertId(String expertId);

  Future<ExpertAvailability> saveByExpertId({
    required String expertId,
    required ExpertAvailability availability,
  });
}

final class ExpertAvailabilityRepositoryException implements Exception {
  const ExpertAvailabilityRepositoryException({
    required this.cause,
    this.malformedData = false,
  });

  final Object cause;
  final bool malformedData;
}

final class ExpertAvailabilityConcurrencyException implements Exception {
  const ExpertAvailabilityConcurrencyException({
    required this.expectedRevision,
    required this.actualRevision,
  });

  final String? expectedRevision;
  final String? actualRevision;
}
