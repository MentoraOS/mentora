import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/consultation_brief/consultation_brief.dart';

/// Persists briefs at `consultation_briefs/{bookingId}`.
///
/// The document id IS the Booking reference; the booking engine is
/// untouched. Saving runs in a transaction that verifies the booking exists
/// and belongs to the writing client (fail closed). Reading is tolerant:
/// absent documents yield null, malformed fields fall back to empty strings
/// where optional.
final class FirestoreConsultationBriefRepository
    implements ConsultationBriefRepository {
  const FirestoreConsultationBriefRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<void> save({
    required String bookingId,
    required String clientId,
    required ConsultationBrief brief,
  }) async {
    final bookingDocument = _firestore.collection('bookings').doc(bookingId);
    final briefDocument = _firestore
        .collection('consultation_briefs')
        .doc(bookingId);

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final booking = await transaction.get(bookingDocument);
        final data = booking.data();
        if (!booking.exists || data == null || data['clientId'] != clientId) {
          throw const ConsultationBriefBookingNotFoundException();
        }

        transaction.set(briefDocument, <String, dynamic>{
          'bookingId': bookingId,
          'clientId': clientId,
          'objective': brief.objective,
          'description': brief.description,
          'questions': brief.questions,
          'expectedOutcome': brief.expectedOutcome,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } on ConsultationBriefBookingNotFoundException {
      rethrow;
    } catch (error) {
      throw ConsultationBriefRepositoryException(cause: error);
    }
  }

  @override
  Future<ConsultationBrief?> loadByBookingId(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection('consultation_briefs')
          .doc(bookingId)
          .get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;

      final objective = data['objective'];
      final description = data['description'];
      if (objective is! String ||
          objective.trim().isEmpty ||
          description is! String ||
          description.trim().isEmpty) {
        return null;
      }

      return ConsultationBrief(
        objective: objective,
        description: description,
        questions: data['questions'] is String
            ? data['questions'] as String
            : '',
        expectedOutcome: data['expectedOutcome'] is String
            ? data['expectedOutcome'] as String
            : '',
      );
    } catch (error) {
      throw ConsultationBriefRepositoryException(cause: error);
    }
  }
}
