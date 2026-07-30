import '../entities/enterprise_member.dart';

abstract class EnterpriseMemberRepository {
  Future<List<EnterpriseMember>> getMembers({required String workspaceId});

  Future<void> inviteMember({
    required String workspaceId,
    required String email,
    required String role,
    required String department,
  });

  Future<void> removeMember({required String memberId});

  Future<void> updateMemberRole({
    required String memberId,
    required String role,
  });
}
