import 'booking_creation.dart';

abstract interface class BookingCreationRepository {
  Future<String> create(BookingCreation booking);
}

final class BookingCreationConflictException implements Exception {
  const BookingCreationConflictException();
}

final class BookingCreationRepositoryException implements Exception {
  const BookingCreationRepositoryException({
    required this.cause,
    this.malformedData = false,
    this.infrastructureUnavailable = false,
  });

  final Object cause;
  final bool malformedData;
  final bool infrastructureUnavailable;
}
