import '../entities/enterprise_invitation.dart';
import '../repositories/enterprise_invitation_repository.dart';

class GetPendingEnterpriseInvitationsUseCase {
  final EnterpriseInvitationRepository repository;

  const GetPendingEnterpriseInvitationsUseCase(this.repository);

  Future<List<EnterpriseInvitation>> call({required String email}) {
    return repository.getPendingInvitationsForEmail(email: email);
  }
}
