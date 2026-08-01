import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/consultation_summary/consultation_summary.dart';
import '../../domain/consultation_summary/summary_repository.dart';

/// Summary state lives in its own `consultation_summaries` collection,
/// one document per reservation KEYED BY the booking id (summaryId ==
/// bookingId). ONLY metadata is persisted — bookingId, status, createdAt,
/// updatedAt — never any generated content. Writes run in a transaction
/// guarding existence and participation; the booking document is read,
/// never written.
final class FirestoreSummaryRepository implements SummaryRepository {
  const FirestoreSummaryRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _summaries =>
      _firestore.collection('consultation_summaries');

  @override
  Future<void> saveStatus({
    required String bookingId,
    required String userId,
    required SummaryStatus status,
  }) async {
    final bookingDocument = _firestore.collection('bookings').doc(bookingId);
    final summaryDocument = _summaries.doc(bookingId);

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final booking = await transaction.get(bookingDocument);
        final data = booking.data();
        if (!booking.exists || data == null) {
          throw const SummaryStateNotFoundException();
        }
        if (data['clientId'] != userId && data['expertId'] != userId) {
          throw const SummaryStateNotFoundException();
        }

        final existing = await transaction.get(summaryDocument);
        transaction.set(summaryDocument, <String, dynamic>{
          'bookingId': bookingId,
          'status': status.name,
          if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } on SummaryStateNotFoundException {
      rethrow;
    } catch (error) {
      throw SummaryStateRepositoryException(cause: error);
    }
  }

  @override
  Future<ConsultationSummary?> findByBookingId({
    required String bookingId,
    required String userId,
  }) async {
    try {
      final booking = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .get();
      final data = booking.data();
      if (!booking.exists || data == null) {
        throw const SummaryStateNotFoundException();
      }
      if (data['clientId'] != userId && data['expertId'] != userId) {
        throw const SummaryStateNotFoundException();
      }

      final snapshot = await _summaries.doc(bookingId).get();
      final summary = snapshot.data();
      if (!snapshot.exists || summary == null) return null;

      final createdAt = summary['createdAt'];
      final updatedAt = summary['updatedAt'];
      return ConsultationSummary(
        bookingId: bookingId,
        status: SummaryStatus.values.firstWhere(
          (status) => status.name == summary['status'],
          orElse: () => SummaryStatus.notGenerated,
        ),
        createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
        updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
      );
    } on SummaryStateNotFoundException {
      rethrow;
    } catch (error) {
      throw SummaryStateRepositoryException(cause: error);
    }
  }
}
