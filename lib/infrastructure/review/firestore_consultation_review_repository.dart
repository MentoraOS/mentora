import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/review/consultation_review.dart';
import '../../domain/review/consultation_review_repository.dart';

/// Reviews live in their own `consultation_reviews` collection, one document
/// per reservation, keyed BY the booking id — the storage itself makes a
/// second review impossible. Submission runs in a transaction: the booking
/// must exist, belong to the caller (foreign reads as not-found) and be
/// completed; the authoritative expert identity is read from the booking.
/// The booking document is never written; nothing is counted or aggregated.
final class FirestoreConsultationReviewRepository
    implements ConsultationReviewRepository {
  const FirestoreConsultationReviewRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection('consultation_reviews');

  @override
  Future<void> submit({
    required String bookingId,
    required String clientId,
    required int rating,
    required String comment,
  }) async {
    final bookingDocument = _firestore.collection('bookings').doc(bookingId);
    final reviewDocument = _reviews.doc(bookingId);

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final booking = await transaction.get(bookingDocument);
        final data = booking.data();
        if (!booking.exists || data == null) {
          throw const ConsultationReviewBookingNotFoundException();
        }
        if (data['clientId'] != clientId) {
          throw const ConsultationReviewBookingNotFoundException();
        }
        if (data['status'] != 'completed') {
          final status = data['status'];
          throw ConsultationReviewStateException(
            currentStatus: status is String ? status : 'unknown',
          );
        }

        final existing = await transaction.get(reviewDocument);
        if (existing.exists) {
          throw const ConsultationReviewAlreadyExistsException();
        }

        transaction.set(reviewDocument, <String, dynamic>{
          'bookingId': bookingId,
          'expertId': data['expertId'],
          'clientId': clientId,
          'rating': rating,
          'comment': comment,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } on ConsultationReviewBookingNotFoundException {
      rethrow;
    } on ConsultationReviewStateException {
      rethrow;
    } on ConsultationReviewAlreadyExistsException {
      rethrow;
    } catch (error) {
      throw ConsultationReviewRepositoryException(cause: error);
    }
  }

  @override
  Future<ConsultationReview?> findByBookingId(String bookingId) async {
    try {
      final snapshot = await _reviews.doc(bookingId).get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return _toReview(snapshot.id, data);
    } catch (error) {
      throw ConsultationReviewRepositoryException(cause: error);
    }
  }

  @override
  Future<List<ConsultationReview>> listByExpertId(String expertId) async {
    try {
      // Ordering happens in the Application layer; a plain equality query
      // keeps the collection free of composite-index requirements.
      final snapshot = await _reviews
          .where('expertId', isEqualTo: expertId)
          .get();
      return [
        for (final document in snapshot.docs)
          _toReview(document.id, document.data()),
      ];
    } catch (error) {
      throw ConsultationReviewRepositoryException(cause: error);
    }
  }

  static ConsultationReview _toReview(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    final rating = data['rating'];
    return ConsultationReview(
      reviewId: id,
      bookingId: data['bookingId'] is String ? data['bookingId'] as String : id,
      expertId: data['expertId'] is String ? data['expertId'] as String : '',
      clientId: data['clientId'] is String ? data['clientId'] as String : '',
      rating: rating is int && rating >= 1 && rating <= 5 ? rating : 1,
      comment: data['comment'] is String ? data['comment'] as String : '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }
}
