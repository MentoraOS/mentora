import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/booking/booking_cancellation_repository.dart';

/// Transitions `bookings/{id}` to `cancelled`.
///
/// The transition runs in a transaction: the reservation must exist, belong
/// to the cancelling client, and be in a cancellable state. The update is
/// partial — every reservation fact (commercial snapshot, temporal snapshot,
/// history) is kept; only the lifecycle fields change. `cancelledAt` is
/// write-audit metadata, not expiration authority. A `cancelled` status is
/// outside the occupancy read filter, so the slot stops displaying as
/// occupied; the ARCH-008 creation guard is deliberately untouched (slot
/// release is the future conflict/release contract).
final class FirestoreBookingCancellationRepository
    implements BookingCancellationRepository {
  const FirestoreBookingCancellationRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// States a client may cancel. A completed or already-cancelled
  /// consultation is not cancellable.
  static const Set<String> _cancellableStatuses = {
    'pending_payment',
    'pending',
    'confirmed',
    'paid',
  };

  @override
  Future<void> cancel({
    required String bookingId,
    required String clientId,
  }) async {
    final document = _firestore.collection('bookings').doc(bookingId);

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(document);
        final data = snapshot.data();
        if (!snapshot.exists || data == null) {
          throw const BookingCancellationNotFoundException();
        }
        // A foreign booking is reported as not-found, never as a state hint.
        if (data['clientId'] != clientId) {
          throw const BookingCancellationNotFoundException();
        }

        final status = data['status'];
        if (status is! String || !_cancellableStatuses.contains(status)) {
          throw BookingCancellationStateException(
            currentStatus: status is String ? status : 'unknown',
          );
        }

        transaction.update(document, <String, dynamic>{
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
          'cancelledBy': 'client',
        });
      });
    } on BookingCancellationNotFoundException {
      rethrow;
    } on BookingCancellationStateException {
      rethrow;
    } catch (error) {
      throw BookingCancellationRepositoryException(cause: error);
    }
  }
}
