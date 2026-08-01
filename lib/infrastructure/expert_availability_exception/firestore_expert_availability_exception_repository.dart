import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/expert_availability_exception/expert_availability_exception.dart';

/// Persists unavailability windows in the dedicated
/// `expert_availability_exceptions` collection. The expert document and the
/// recurring availability are never written. Reads are tolerant: malformed
/// documents are skipped, never invented.
final class FirestoreExpertAvailabilityExceptionRepository
    implements ExpertAvailabilityExceptionRepository {
  const FirestoreExpertAvailabilityExceptionRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection('expert_availability_exceptions');
  }

  @override
  Future<void> create({
    required String expertId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    try {
      await _collection.add(<String, dynamic>{
        'expertId': expertId,
        'startDate': startDate,
        'endDate': endDate,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw ExpertAvailabilityExceptionRepositoryException(cause: error);
    }
  }

  @override
  Future<List<ExpertAvailabilityException>> listByExpertId(
    String expertId,
  ) async {
    try {
      final snapshot = await _collection
          .where('expertId', isEqualTo: expertId)
          .get();

      final exceptions = <ExpertAvailabilityException>[];
      for (final document in snapshot.docs) {
        final parsed = _fromDocument(document.id, document.data());
        if (parsed != null) exceptions.add(parsed);
      }
      // In-memory ordering avoids a composite index.
      exceptions.sort((a, b) => a.startDate.compareTo(b.startDate));
      return List.unmodifiable(exceptions);
    } catch (error) {
      throw ExpertAvailabilityExceptionRepositoryException(cause: error);
    }
  }

  @override
  Future<void> delete({required String id, required String expertId}) async {
    try {
      final document = _collection.doc(id);
      final snapshot = await document.get();
      final data = snapshot.data();
      // A foreign exception reads as not-found, never as a hint.
      if (!snapshot.exists || data == null || data['expertId'] != expertId) {
        throw const ExpertAvailabilityExceptionNotFoundException();
      }
      await document.delete();
    } on ExpertAvailabilityExceptionNotFoundException {
      rethrow;
    } catch (error) {
      throw ExpertAvailabilityExceptionRepositoryException(cause: error);
    }
  }

  ExpertAvailabilityException? _fromDocument(
    String id,
    Map<String, dynamic> data,
  ) {
    final expertId = data['expertId'];
    final startDate = data['startDate'];
    final endDate = data['endDate'];
    final reason = data['reason'];
    if (expertId is! String ||
        startDate is! String ||
        endDate is! String ||
        reason is! String) {
      return null;
    }
    try {
      return ExpertAvailabilityException(
        id: id,
        expertId: expertId,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );
    } on ArgumentError {
      return null;
    }
  }
}
