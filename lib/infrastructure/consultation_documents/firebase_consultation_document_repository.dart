import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/consultation_documents/consultation_shared_document.dart';

/// Stores shared files in Firebase Storage and their metadata in Firestore.
///
/// Blobs live at `consultation_documents/{bookingId}/{docId}_{fileName}`;
/// metadata at the `consultation_documents` collection. Every operation
/// first loads the booking and verifies the caller is its client or expert —
/// foreign users and missing bookings fail closed identically. Only URL,
/// name and size are kept: no thumbnails, no content analysis.
final class FirebaseConsultationDocumentRepository
    implements ConsultationSharedDocumentRepository {
  const FirebaseConsultationDocumentRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Future<void> upload({
    required String bookingId,
    required String userId,
    required String fileName,
    required List<int> bytes,
  }) async {
    try {
      final role = await _requireParticipantRole(bookingId, userId);

      final document = _firestore.collection('consultation_documents').doc();
      final blob = _storage.ref().child(
        'consultation_documents/$bookingId/${document.id}_$fileName',
      );

      await blob.putData(Uint8List.fromList(bytes));
      final url = await blob.getDownloadURL();

      await document.set(<String, dynamic>{
        'bookingId': bookingId,
        'uploadedBy': userId,
        'uploaderRole': role,
        'fileName': fileName,
        'fileSize': bytes.length,
        'fileUrl': url,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on ConsultationDocumentBookingNotFoundException {
      rethrow;
    } catch (error) {
      throw ConsultationDocumentRepositoryException(cause: error);
    }
  }

  @override
  Future<List<ConsultationSharedDocument>> listByBookingId({
    required String bookingId,
    required String userId,
  }) async {
    try {
      await _requireParticipantRole(bookingId, userId);

      final snapshot = await _firestore
          .collection('consultation_documents')
          .where('bookingId', isEqualTo: bookingId)
          .get();

      final documents = snapshot.docs
          .map((document) => _fromMap(document.data()))
          .whereType<ConsultationSharedDocument>()
          .toList();
      // In-memory ordering avoids a composite index; volumes are small.
      documents.sort((a, b) => a.fileName.compareTo(b.fileName));
      return List.unmodifiable(documents);
    } on ConsultationDocumentBookingNotFoundException {
      rethrow;
    } catch (error) {
      throw ConsultationDocumentRepositoryException(cause: error);
    }
  }

  /// The caller's role on the booking, or fail closed.
  Future<String> _requireParticipantRole(
    String bookingId,
    String userId,
  ) async {
    final booking = await _firestore
        .collection('bookings')
        .doc(bookingId)
        .get();
    final data = booking.data();
    if (!booking.exists || data == null) {
      throw const ConsultationDocumentBookingNotFoundException();
    }
    if (data['clientId'] == userId) return 'client';
    if (data['expertId'] == userId) return 'expert';
    throw const ConsultationDocumentBookingNotFoundException();
  }

  ConsultationSharedDocument? _fromMap(Map<String, dynamic> data) {
    final bookingId = data['bookingId'];
    final uploadedBy = data['uploadedBy'];
    final fileName = data['fileName'];
    final fileUrl = data['fileUrl'];
    if (bookingId is! String ||
        uploadedBy is! String ||
        fileName is! String ||
        fileUrl is! String) {
      return null;
    }

    return ConsultationSharedDocument(
      bookingId: bookingId,
      uploadedBy: uploadedBy,
      uploaderRole: data['uploaderRole'] == 'expert' ? 'expert' : 'client',
      fileName: fileName,
      fileSize: data['fileSize'] is int ? data['fileSize'] as int : 0,
      fileUrl: fileUrl,
    );
  }
}
