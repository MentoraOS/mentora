import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/conversation/conversation.dart';
import '../../domain/conversation/conversation_repository.dart';

/// The conversation lives in its own `consultation_conversations`
/// collection, one document per reservation KEYED BY the booking id — a
/// second conversation per reservation is structurally impossible — with
/// its text messages in a `messages` subcollection.
///
/// Sending runs in a transaction: the booking must exist, the sender must
/// be its client or expert (foreign users read as not-found) and the status
/// must be conversational (confirmed, paid, completed). The booking
/// document itself is only read, never written. Real time is exclusively
/// Firestore streams — no polling anywhere.
final class FirestoreConversationRepository implements ConversationRepository {
  const FirestoreConversationRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const Set<String> _conversationalStatuses = {
    'confirmed',
    'paid',
    'completed',
  };

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection('consultation_conversations');

  @override
  Future<void> sendMessage({
    required String bookingId,
    required String senderId,
    required String content,
  }) async {
    final bookingDocument = _firestore.collection('bookings').doc(bookingId);
    final conversationDocument = _conversations.doc(bookingId);
    final messageDocument = conversationDocument.collection('messages').doc();

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final booking = await transaction.get(bookingDocument);
        final data = booking.data();
        if (!booking.exists || data == null) {
          throw const ConversationNotFoundException();
        }
        final role = _roleOf(data, senderId);
        if (role == null) {
          throw const ConversationNotFoundException();
        }
        final status = data['status'];
        if (status is! String || !_conversationalStatuses.contains(status)) {
          throw ConversationStateException(
            currentStatus: status is String ? status : 'unknown',
          );
        }

        transaction.set(conversationDocument, <String, dynamic>{
          'bookingId': bookingId,
          'participants': [data['clientId'], data['expertId']],
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        transaction.set(messageDocument, <String, dynamic>{
          'bookingId': bookingId,
          'senderId': senderId,
          'senderRole': role.name,
          'content': content,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } on ConversationNotFoundException {
      rethrow;
    } on ConversationStateException {
      rethrow;
    } catch (error) {
      throw ConversationRepositoryException(cause: error);
    }
  }

  @override
  Stream<List<Message>> watchMessages({
    required String bookingId,
    required String userId,
  }) async* {
    final DocumentSnapshot<Map<String, dynamic>> booking;
    try {
      booking = await _firestore.collection('bookings').doc(bookingId).get();
    } catch (error) {
      throw ConversationRepositoryException(cause: error);
    }

    final data = booking.data();
    if (!booking.exists || data == null || _roleOf(data, userId) == null) {
      throw const ConversationNotFoundException();
    }
    final status = data['status'];
    if (status is! String || !_conversationalStatuses.contains(status)) {
      throw ConversationStateException(
        currentStatus: status is String ? status : 'unknown',
      );
    }

    yield* _conversations
        .doc(bookingId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => [
            for (final document in snapshot.docs)
              _toMessage(document.id, document.data()),
          ],
        );
  }

  static ConversationRole? _roleOf(Map<String, dynamic> data, String userId) {
    if (data['clientId'] == userId) return ConversationRole.client;
    if (data['expertId'] == userId) return ConversationRole.expert;
    return null;
  }

  static Message _toMessage(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    final content = data['content'];
    return Message(
      id: id,
      bookingId: data['bookingId'] is String
          ? data['bookingId'] as String
          : '',
      senderId: data['senderId'] is String ? data['senderId'] as String : '',
      senderRole: data['senderRole'] == 'expert'
          ? ConversationRole.expert
          : ConversationRole.client,
      content: content is String && content.trim().isNotEmpty
          ? content
          : '(message vide)',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }
}
