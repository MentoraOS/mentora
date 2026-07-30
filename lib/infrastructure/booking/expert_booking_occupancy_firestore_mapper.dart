import '../../domain/booking/expert_booking_occupancy.dart';

final class ExpertBookingOccupancyFirestoreMapper {
  const ExpertBookingOccupancyFirestoreMapper();

  ExpertBookingOccupancy fromMap(Map<String, dynamic> data) {
    final bookingDate = data['bookingDate'];
    final bookingTime = data['bookingTime'];

    if (bookingDate is! String || bookingTime is! String) {
      throw const FormatException(
        'Booking occupancy requires String bookingDate and bookingTime.',
      );
    }

    try {
      return ExpertBookingOccupancy(
        bookingDate: bookingDate,
        bookingTime: bookingTime,
      );
    } on ArgumentError catch (error) {
      throw FormatException('Invalid Booking occupancy identity.', error);
    }
  }
}
