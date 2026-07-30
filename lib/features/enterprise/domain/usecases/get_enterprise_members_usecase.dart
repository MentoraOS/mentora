import '../entities/enterprise_member.dart';
import '../repositories/enterprise_member_repository.dart';

class GetEnterpriseMembersUseCase {
  final EnterpriseMemberRepository repository;

  const GetEnterpriseMembersUseCase(this.repository);

  Future<List<EnterpriseMember>> call({required String workspaceId}) {
    return repository.getMembers(workspaceId: workspaceId);
  }
}
