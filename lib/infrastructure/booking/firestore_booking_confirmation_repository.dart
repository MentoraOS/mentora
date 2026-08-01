import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/booking/booking_confirmation_repository.dart';

/// Transitions `bookings/{id}` from `pending_payment` to `confirmed`.
///
/// The transition runs in a transaction: the reservation must exist, belong
/// to the confirming client, and still await payment. `confirmed` is the
/// status the Wave 2C occupancy read already treats as occupying, so a paid
/// reservation becomes visible occupancy without any read-side change.
/// `confirmedAt` is write-audit metadata, not expiration authority.
final class FirestoreBookingConfirmationRepository
    implements BookingConfirmationRepository {
  const FirestoreBookingConfirmationRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<void> confirmPaid({
    required String bookingId,
    required String clientId,
  }) async {
    final document = _firestore.collection('bookings').doc(bookingId);

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(document);
        final data = snapshot.data();
        if (!snapshot.exists || data == null) {
          throw const BookingConfirmationNotFoundException();
        }
        // A foreign booking is reported as not-found, never as a state hint.
        if (data['clientId'] != clientId) {
          throw const BookingConfirmationNotFoundException();
        }

        final status = data['status'];
        if (status != 'pending_payment') {
          throw BookingConfirmationStateException(
            currentStatus: status is String ? status : 'unknown',
          );
        }

        transaction.update(document, <String, dynamic>{
          'status': 'confirmed',
          'paymentStatus': 'paid',
          'confirmedAt': FieldValue.serverTimestamp(),
        });
      });
    } on BookingConfirmationNotFoundException {
      rethrow;
    } on BookingConfirmationStateException {
      rethrow;
    } catch (error) {
      throw BookingConfirmationRepositoryException(cause: error);
    }
  }
}
