import '../../application/workspace/workspace_state_projection.dart';
import '../../core/identity/identity.dart';
import '../../domain/workspace/workspace_membership.dart';

final class IdentityWorkspaceStateProjection
    implements WorkspaceStateProjection {
  const IdentityWorkspaceStateProjection();

  @override
  void project({
    required String userId,
    required List<WorkspaceMembership> memberships,
    required String currentWorkspaceId,
  }) {
    IdentityEngine.setMemberships(
      memberships
          .map(
            (membership) => Membership(
              id: membership.workspaceId,
              identityId: userId,
              workspaceId: membership.workspaceId,
              workspaceType: membership.workspaceType.name,
              role: membership.role,
              permissions: membership.permissions,
              organizationId: membership.organizationId,
              departmentId: membership.departmentId,
              active: true,
            ),
          )
          .toList(),
    );
    IdentityEngine.switchMembership(currentWorkspaceId);
  }

  @override
  void clear() {
    IdentityEngine.clear();
  }
}
