import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/enterprise_member.dart';
import '../../domain/repositories/enterprise_member_repository.dart';

class FirestoreEnterpriseMemberRepository
    implements EnterpriseMemberRepository {
  final FirebaseFirestore firestore;

  const FirestoreEnterpriseMemberRepository({required this.firestore});

  @override
  Future<List<EnterpriseMember>> getMembers({
    required String workspaceId,
  }) async {
    final snapshot = await firestore
        .collection('workspace_members')
        .where('workspaceId', isEqualTo: workspaceId)
        .where('active', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return EnterpriseMember(
        id: doc.id,
        workspaceId: data['workspaceId'] ?? '',
        userId: data['userId'] ?? '',
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? '',
        department: data['department'] ?? '',
        active: data['active'] ?? true,
      );
    }).toList();
  }

  @override
  Future<void> inviteMember({
    required String workspaceId,
    required String email,
    required String role,
    required String department,
  }) async {
    await firestore.collection('workspace_invitations').add({
      'workspaceId': workspaceId,
      'email': email,
      'role': role,
      'department': department,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeMember({required String memberId}) async {
    await firestore.collection('workspace_members').doc(memberId).update({
      'active': false,
      'removedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateMemberRole({
    required String memberId,
    required String role,
  }) async {
    await firestore.collection('workspace_members').doc(memberId).update({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
