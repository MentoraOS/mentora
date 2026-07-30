import 'workspace_member.dart';

abstract interface class WorkspaceMemberRepository {
  Future<List<WorkspaceMember>> loadMembers(String workspaceId);
}
