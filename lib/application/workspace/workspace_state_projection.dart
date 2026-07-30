import '../../domain/workspace/workspace_membership.dart';

abstract interface class WorkspaceStateProjection {
  void project({
    required String userId,
    required List<WorkspaceMembership> memberships,
    required String currentWorkspaceId,
  });

  void clear();
}
