import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/gateways/enterprise_gateway.dart';

class FirestoreEnterpriseGateway implements EnterpriseGateway {
  final FirebaseFirestore firestore;

  const FirestoreEnterpriseGateway({required this.firestore});

  @override
  Future<void> acceptInvitation({
    required String invitationId,
    required String receiverUserId,
  }) async {
    final invitationRef = firestore
        .collection('workspace_invitations')
        .doc(invitationId);

    await firestore.runTransaction((transaction) async {
      final invitationSnapshot = await transaction.get(invitationRef);

      if (!invitationSnapshot.exists) {
        throw Exception('Invitation introuvable');
      }

      final data = invitationSnapshot.data()!;

      if (data['status'] != 'pending') {
        throw Exception('Invitation déjà traitée');
      }

      final workspaceId = data['workspaceId'] ?? '';
      final workspaceName = data['workspaceName'] ?? '';
      final workspaceType = 'company';
      final role = data['role'] ?? 'member';
      final department = data['department'] ?? '';

      final membershipRef = firestore
          .collection('workspace_memberships')
          .doc('${receiverUserId}_$workspaceId');

      final memberRef = firestore
          .collection('workspace_members')
          .doc('${workspaceId}_$receiverUserId');

      transaction.set(membershipRef, {
        'userId': receiverUserId,
        'workspaceId': workspaceId,
        'workspaceName': workspaceName,
        'workspaceType': workspaceType,
        'organizationId': workspaceId,
        'departmentId': department.toString().toLowerCase(),
        'role': role,
        'permissions': <String>[],
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.set(memberRef, {
        'workspaceId': workspaceId,
        'userId': receiverUserId,
        'firstName': '',
        'lastName': '',
        'email': data['receiverEmail'] ?? '',
        'role': role,
        'department': department,
        'avatar': '',
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(invitationRef, {
        'receiverUserId': receiverUserId,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
