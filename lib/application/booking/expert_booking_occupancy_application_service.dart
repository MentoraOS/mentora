import '../../domain/booking/expert_booking_occupancy.dart';
import '../../domain/booking/expert_booking_occupancy_repository.dart';
import 'expert_booking_occupancy_failure.dart';

final class ExpertBookingOccupancyApplicationService {
  const ExpertBookingOccupancyApplicationService({
    required ExpertBookingOccupancyRepository repository,
  }) : _repository = repository;

  final ExpertBookingOccupancyRepository _repository;

  Future<List<ExpertBookingOccupancy>> loadForExpert(String expertId) async {
    if (expertId.trim().isEmpty) {
      throw const ExpertBookingOccupancyInvalidRequestFailure();
    }

    try {
      final occupancies = await _repository.loadForExpert(expertId);
      return List<ExpertBookingOccupancy>.unmodifiable(occupancies);
    } on ExpertBookingOccupancyRepositoryException catch (error) {
      if (error.malformedData) {
        throw ExpertBookingOccupancyMalformedDataFailure(cause: error.cause);
      }
      throw ExpertBookingOccupancyReadFailure(cause: error.cause);
    } catch (error) {
      throw ExpertBookingOccupancyReadFailure(cause: error);
    }
  }
}
