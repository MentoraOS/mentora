import '../repositories/enterprise_invitation_repository.dart';

class SendEnterpriseInvitationUseCase {
  final EnterpriseInvitationRepository repository;

  const SendEnterpriseInvitationUseCase(this.repository);

  Future<void> call({
    required String workspaceId,
    required String workspaceName,
    required String senderId,
    required String receiverEmail,
    required String role,
    required String department,
  }) {
    return repository.sendInvitation(
      workspaceId: workspaceId,
      workspaceName: workspaceName,
      senderId: senderId,
      receiverEmail: receiverEmail,
      role: role,
      department: department,
    );
  }
}
