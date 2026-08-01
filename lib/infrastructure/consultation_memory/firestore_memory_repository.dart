import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/consultation_memory/consultation_memory.dart';
import '../../domain/consultation_memory/memory_repository.dart';

/// The memory lives in its own `consultation_memories` collection, one
/// document per reservation KEYED BY the booking id (memoryId ==
/// bookingId), with its facts in an `entries` subcollection.
///
/// Recording runs in a transaction: the booking must exist and the caller
/// must be its client or expert (foreign users read as not-found). The
/// booking document is only read, never written. Payloads are stored
/// verbatim and opaquely — nothing is parsed, interpreted or transformed.
final class FirestoreMemoryRepository implements MemoryRepository {
  const FirestoreMemoryRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _memories =>
      _firestore.collection('consultation_memories');

  @override
  Future<void> record({
    required String bookingId,
    required String userId,
    required MemoryEntryType type,
    required Map<String, Object?> payload,
  }) async {
    final bookingDocument = _firestore.collection('bookings').doc(bookingId);
    final memoryDocument = _memories.doc(bookingId);
    final entryDocument = memoryDocument.collection('entries').doc();

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final booking = await transaction.get(bookingDocument);
        final data = booking.data();
        if (!booking.exists || data == null) {
          throw const MemoryEntryNotFoundException();
        }
        if (data['clientId'] != userId && data['expertId'] != userId) {
          throw const MemoryEntryNotFoundException();
        }

        transaction.set(memoryDocument, <String, dynamic>{
          'bookingId': bookingId,
          'participants': [data['clientId'], data['expertId']],
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        transaction.set(entryDocument, <String, dynamic>{
          'bookingId': bookingId,
          'type': type.name,
          'payload': payload,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } on MemoryEntryNotFoundException {
      rethrow;
    } catch (error) {
      throw MemoryEntryRepositoryException(cause: error);
    }
  }

  @override
  Future<ConsultationMemory> read({
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
        throw const MemoryEntryNotFoundException();
      }
      if (data['clientId'] != userId && data['expertId'] != userId) {
        throw const MemoryEntryNotFoundException();
      }

      final memory = await _memories.doc(bookingId).get();
      final entries = await _memories
          .doc(bookingId)
          .collection('entries')
          .orderBy('createdAt')
          .get();

      final memoryCreatedAt = memory.data()?['createdAt'];
      return ConsultationMemory(
        bookingId: bookingId,
        entries: [
          for (final document in entries.docs)
            _toEntry(document.id, document.data()),
        ],
        createdAt: memoryCreatedAt is Timestamp
            ? memoryCreatedAt.toDate()
            : null,
      );
    } on MemoryEntryNotFoundException {
      rethrow;
    } catch (error) {
      throw MemoryEntryRepositoryException(cause: error);
    }
  }

  static MemoryEntry _toEntry(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    final payload = data['payload'];
    return MemoryEntry(
      id: id,
      bookingId: data['bookingId'] is String
          ? data['bookingId'] as String
          : id,
      type: MemoryEntryType.values.firstWhere(
        (type) => type.name == data['type'],
        orElse: () => MemoryEntryType.chatMessage,
      ),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      payload: payload is Map<String, dynamic>
          ? Map<String, Object?>.from(payload)
          : const {},
    );
  }
}
