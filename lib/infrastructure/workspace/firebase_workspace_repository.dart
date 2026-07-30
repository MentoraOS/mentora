import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/workspace/workspace_membership.dart';
import '../../domain/workspace/workspace_repository.dart';
import '../../domain/workspace/workspace_type.dart';

final class FirebaseWorkspaceRepository implements WorkspaceRepository {
  const FirebaseWorkspaceRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<WorkspaceMembership>> membershipsForUser(String userId) async {
    final snapshot = await _firestore
        .collection('workspace_memberships')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return WorkspaceMembership(
        workspaceId: data['workspaceId'] ?? '',
        workspaceType: _typeFromString(data['workspaceType'] ?? ''),
        workspaceName: data['workspaceName'] ?? 'Workspace',
        organizationId: data['organizationId'],
        departmentId: data['departmentId'],
        role: data['role'] ?? 'member',
        permissions: List<String>.from(data['permissions'] ?? const <String>[]),
      );
    }).toList();
  }

  WorkspaceType _typeFromString(String value) {
    switch (value) {
      case 'expert':
        return WorkspaceType.expert;

      case 'company':
        return WorkspaceType.company;

      case 'university':
        return WorkspaceType.university;

      case 'government':
        return WorkspaceType.government;

      case 'ngo':
        return WorkspaceType.ngo;

      default:
        return WorkspaceType.personal;
    }
  }
}
