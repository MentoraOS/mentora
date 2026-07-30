import '../repositories/enterprise_member_repository.dart';

class RemoveEnterpriseMemberUseCase {
  final EnterpriseMemberRepository repository;

  const RemoveEnterpriseMemberUseCase(this.repository);

  Future<void> call({required String memberId}) {
    return repository.removeMember(memberId: memberId);
  }
}
