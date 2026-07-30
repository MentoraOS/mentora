import '../repositories/enterprise_invitation_repository.dart';

class RejectEnterpriseInvitationUseCase {
  final EnterpriseInvitationRepository repository;

  const RejectEnterpriseInvitationUseCase(this.repository);

  Future<void> call({required String invitationId}) {
    return repository.rejectInvitation(invitationId: invitationId);
  }
}
