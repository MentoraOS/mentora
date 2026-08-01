import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/booking/booking_reschedule_repository.dart';

/// Applies a revalidated reschedule to `bookings/{id}`.
///
/// The transition runs in a transaction: the reservation must exist, belong
/// to the rescheduling client, be in a reschedulable state, and the new
/// occurrence must match the reservation's snapshotted duration (AD-022
/// decision 3) — so a tampered duration can never move a booking. The update
/// is partial: every fact is kept, the previous canonical boundaries are
/// preserved as `previousStartUtc`/`previousEndUtc` when they exist, and
/// `rescheduledAt` is write-audit metadata, not expiration authority.
final class FirestoreBookingRescheduleRepository
    implements BookingRescheduleRepository {
  const FirestoreBookingRescheduleRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// States a client may reschedule; a completed or cancelled consultation
  /// cannot move.
  static const Set<String> _reschedulableStatuses = {
    'pending_payment',
    'pending',
    'confirmed',
    'paid',
  };

  @override
  Future<void> reschedule({
    required String bookingId,
    required String clientId,
    required BookingRescheduleUpdate update,
  }) async {
    final document = _firestore.collection('bookings').doc(bookingId);

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(document);
        final data = snapshot.data();
        if (!snapshot.exists || data == null) {
          throw const BookingRescheduleNotFoundException();
        }
        // A foreign booking is reported as not-found, never as a state hint.
        if (data['clientId'] != clientId) {
          throw const BookingRescheduleNotFoundException();
        }

        final status = data['status'];
        if (status is! String || !_reschedulableStatuses.contains(status)) {
          throw BookingRescheduleStateException(
            currentStatus: status is String ? status : 'unknown',
          );
        }

        // AD-022 decision 3: the occurrence length equals the snapshotted
        // duration. An absent or different duration fails closed.
        final duration = data['duration'];
        final newMinutes = update.endUtc.difference(update.startUtc).inMinutes;
        if (duration is! int || duration != newMinutes) {
          throw const BookingRescheduleConsistencyException();
        }

        final changes = <String, dynamic>{
          'startUtc': Timestamp.fromDate(update.startUtc),
          'endUtc': Timestamp.fromDate(update.endUtc),
          'expertTimezone': update.expertTimezone,
          'bookingDate': update.bookingDate,
          'bookingTime': update.bookingTime,
          'rescheduledAt': FieldValue.serverTimestamp(),
        };
        // History: keep the replaced canonical boundaries when they exist.
        if (data['startUtc'] != null) {
          changes['previousStartUtc'] = data['startUtc'];
        }
        if (data['endUtc'] != null) {
          changes['previousEndUtc'] = data['endUtc'];
        }

        transaction.update(document, changes);
      });
    } on BookingRescheduleNotFoundException {
      rethrow;
    } on BookingRescheduleStateException {
      rethrow;
    } on BookingRescheduleConsistencyException {
      rethrow;
    } catch (error) {
      throw BookingRescheduleRepositoryException(cause: error);
    }
  }
}
