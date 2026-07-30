import 'workspace_membership.dart';

abstract interface class WorkspaceRepository {
  Future<List<WorkspaceMembership>> membershipsForUser(String userId);
}
