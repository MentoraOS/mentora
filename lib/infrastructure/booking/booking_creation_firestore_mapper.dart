import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/booking/booking_creation.dart';

final class BookingCreationFirestoreMapper {
  const BookingCreationFirestoreMapper();

  Map<String, dynamic> toMap(BookingCreation booking) {
    return <String, dynamic>{
      'clientId': booking.clientId,
      'expertId': booking.expertId,
      'expertName': booking.expertName,
      'bookingDate': booking.bookingDate,
      'bookingTime': booking.bookingTime,
      'offerId': booking.offerId,
      'duration': booking.durationMinutes,
      'amount': booking.amountMinor,
      'currency': booking.currency,
      'paymentStatus': BookingCreation.paymentStatus,
      'status': BookingCreation.initialStatus,
      'agoraChannel': booking.agoraChannel,
      'clientNeed': booking.clientNeed,
      'aiSummary': booking.aiSummary,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
