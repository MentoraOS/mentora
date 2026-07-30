import 'expert_booking_occupancy.dart';

abstract interface class ExpertBookingOccupancyRepository {
  Future<List<ExpertBookingOccupancy>> loadForExpert(String expertId);
}

final class ExpertBookingOccupancyRepositoryException implements Exception {
  const ExpertBookingOccupancyRepositoryException({
    required this.cause,
    this.malformedData = false,
  });

  final Object cause;
  final bool malformedData;
}
