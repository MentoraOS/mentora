import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/consultation_notes/consultation_private_notes_repository.dart';

/// Persists private notes at `consultation_private_notes/{bookingId}`.
///
/// Saving runs in a transaction verifying that the booking exists AND is the
/// writing expert's own (fail closed); the booking document itself is never
/// written. Reading returns null for absent documents and for notes stored
/// by another expert — content never leaks across identities.
final class FirestoreConsultationPrivateNotesRepository
    implements ConsultationPrivateNotesRepository {
  const FirestoreConsultationPrivateNotesRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<void> save({
    required String bookingId,
    required String expertId,
    required String notes,
  }) async {
    final bookingDocument = _firestore.collection('bookings').doc(bookingId);
    final notesDocument = _firestore
        .collection('consultation_private_notes')
        .doc(bookingId);

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final booking = await transaction.get(bookingDocument);
        final data = booking.data();
        if (!booking.exists || data == null || data['expertId'] != expertId) {
          throw const ConsultationPrivateNotesBookingNotFoundException();
        }

        transaction.set(notesDocument, <String, dynamic>{
          'bookingId': bookingId,
          'expertId': expertId,
          'notes': notes,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on ConsultationPrivateNotesBookingNotFoundException {
      rethrow;
    } catch (error) {
      throw ConsultationPrivateNotesRepositoryException(cause: error);
    }
  }

  @override
  Future<String?> loadByBookingId({
    required String bookingId,
    required String expertId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('consultation_private_notes')
          .doc(bookingId)
          .get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      // Never leak another expert's notes.
      if (data['expertId'] != expertId) return null;

      final notes = data['notes'];
      if (notes is! String || notes.trim().isEmpty) return null;
      return notes;
    } catch (error) {
      throw ConsultationPrivateNotesRepositoryException(cause: error);
    }
  }
}
