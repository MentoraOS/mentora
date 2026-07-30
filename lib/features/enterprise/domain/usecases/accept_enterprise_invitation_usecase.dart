import '../repositories/enterprise_invitation_repository.dart';

class AcceptEnterpriseInvitationUseCase {
  final EnterpriseInvitationRepository repository;

  const AcceptEnterpriseInvitationUseCase(this.repository);

  Future<void> call({
    required String invitationId,
    required String receiverUserId,
  }) {
    return repository.acceptInvitation(
      invitationId: invitationId,
      receiverUserId: receiverUserId,
    );
  }
}
