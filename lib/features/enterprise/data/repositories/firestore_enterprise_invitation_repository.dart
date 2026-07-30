import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/enterprise_invitation.dart';
import '../../domain/repositories/enterprise_invitation_repository.dart';

class FirestoreEnterpriseInvitationRepository
    implements EnterpriseInvitationRepository {
  final FirebaseFirestore firestore;

  const FirestoreEnterpriseInvitationRepository({required this.firestore});

  @override
  Future<void> sendInvitation({
    required String workspaceId,
    required String workspaceName,
    required String senderId,
    required String receiverEmail,
    required String role,
    required String department,
  }) async {
    await firestore.collection('workspace_invitations').add({
      'workspaceId': workspaceId,
      'workspaceName': workspaceName,
      'senderId': senderId,
      'receiverEmail': receiverEmail.trim().toLowerCase(),
      'receiverUserId': null,
      'role': role,
      'department': department,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'acceptedAt': null,
      'rejectedAt': null,
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 7)),
      ),
    });
  }

  @override
  Future<List<EnterpriseInvitation>> getPendingInvitationsForEmail({
    required String email,
  }) async {
    final snapshot = await firestore
        .collection('workspace_invitations')
        .where('receiverEmail', isEqualTo: email.trim().toLowerCase())
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return EnterpriseInvitation(
        id: doc.id,
        workspaceId: data['workspaceId'] ?? '',
        workspaceName: data['workspaceName'] ?? '',
        senderId: data['senderId'] ?? '',
        receiverEmail: data['receiverEmail'] ?? '',
        receiverUserId: data['receiverUserId'],
        role: data['role'] ?? '',
        department: data['department'] ?? '',
        status: data['status'] ?? 'pending',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
        rejectedAt: (data['rejectedAt'] as Timestamp?)?.toDate(),
        expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      );
    }).toList();
  }

  @override
  Future<void> acceptInvitation({
    required String invitationId,
    required String receiverUserId,
  }) async {
    await firestore
        .collection('workspace_invitations')
        .doc(invitationId)
        .update({
          'receiverUserId': receiverUserId,
          'status': 'accepted',
          'acceptedAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> rejectInvitation({required String invitationId}) async {
    await firestore
        .collection('workspace_invitations')
        .doc(invitationId)
        .update({
          'status': 'rejected',
          'rejectedAt': FieldValue.serverTimestamp(),
        });
  }
}
