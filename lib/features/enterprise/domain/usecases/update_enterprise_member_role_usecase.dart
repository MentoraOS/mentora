import '../repositories/enterprise_member_repository.dart';

class UpdateEnterpriseMemberRoleUseCase {
  final EnterpriseMemberRepository repository;

  const UpdateEnterpriseMemberRoleUseCase(this.repository);

  Future<void> call({required String memberId, required String role}) {
    return repository.updateMemberRole(memberId: memberId, role: role);
  }
}
