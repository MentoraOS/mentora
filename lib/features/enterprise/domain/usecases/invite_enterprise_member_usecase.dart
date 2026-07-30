import '../repositories/enterprise_member_repository.dart';

class InviteEnterpriseMemberUseCase {
  final EnterpriseMemberRepository repository;

  const InviteEnterpriseMemberUseCase(this.repository);

  Future<void> call({
    required String workspaceId,
    required String email,
    required String role,
    required String department,
  }) {
    return repository.inviteMember(
      workspaceId: workspaceId,
      email: email,
      role: role,
      department: department,
    );
  }
}
