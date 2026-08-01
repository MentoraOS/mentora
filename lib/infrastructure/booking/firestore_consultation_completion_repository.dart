import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/booking/consultation_completion_repository.dart';

/// Transitions `bookings/{id}` from `confirmed`/`paid` to `completed`.
///
/// The transition runs in a transaction: the reservation must exist, the
/// caller must be its client or expert (anything else reads as not-found),
/// and the state must be completable. The update writes ONLY the status and
/// `completedAt` — the temporal snapshot, commercial snapshot, legacy fields
/// and history are untouched.
final class FirestoreConsultationCompletionRepository
    implements ConsultationCompletionRepository {
  const FirestoreConsultationCompletionRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const Set<String> _completableStatuses = {'confirmed', 'paid'};

  @override
  Future<void> complete({
    required String bookingId,
    required String userId,
  }) async {
    final document = _firestore.collection('bookings').doc(bookingId);

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(document);
        final data = snapshot.data();
        if (!snapshot.exists || data == null) {
          throw const ConsultationCompletionNotFoundException();
        }
        // Participants only; foreign users read as not-found.
        if (data['clientId'] != userId && data['expertId'] != userId) {
          throw const ConsultationCompletionNotFoundException();
        }

        final status = data['status'];
        if (status is! String || !_completableStatuses.contains(status)) {
          throw ConsultationCompletionStateException(
            currentStatus: status is String ? status : 'unknown',
          );
        }

        transaction.update(document, <String, dynamic>{
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });
      });
    } on ConsultationCompletionNotFoundException {
      rethrow;
    } on ConsultationCompletionStateException {
      rethrow;
    } catch (error) {
      throw ConsultationCompletionRepositoryException(cause: error);
    }
  }
}
