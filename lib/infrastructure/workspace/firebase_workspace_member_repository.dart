import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/workspace/workspace_member.dart';
import '../../domain/workspace/workspace_member_repository.dart';

final class FirebaseWorkspaceMemberRepository
    implements WorkspaceMemberRepository {
  const FirebaseWorkspaceMemberRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<WorkspaceMember>> loadMembers(String workspaceId) async {
    final snapshot = await _firestore
        .collection('workspace_members')
        .where('workspaceId', isEqualTo: workspaceId)
        .where('active', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return WorkspaceMember(
        id: doc.id,
        workspaceId: data['workspaceId'] ?? '',
        userId: data['userId'] ?? '',
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? '',
        department: data['department'] ?? '',
        avatar: data['avatar'] ?? '',
        active: data['active'] ?? true,
      );
    }).toList();
  }
}
