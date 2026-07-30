sealed class ExpertBookingOccupancyFailure implements Exception {
  const ExpertBookingOccupancyFailure();
}

final class ExpertBookingOccupancyInvalidRequestFailure
    extends ExpertBookingOccupancyFailure {
  const ExpertBookingOccupancyInvalidRequestFailure();
}

final class ExpertBookingOccupancyReadFailure
    extends ExpertBookingOccupancyFailure {
  const ExpertBookingOccupancyReadFailure({required this.cause});

  final Object cause;
}

final class ExpertBookingOccupancyMalformedDataFailure
    extends ExpertBookingOccupancyFailure {
  const ExpertBookingOccupancyMalformedDataFailure({required this.cause});

  final Object cause;
}
