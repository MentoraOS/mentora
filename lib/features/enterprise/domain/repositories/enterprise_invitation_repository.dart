import '../entities/enterprise_invitation.dart';

abstract class EnterpriseInvitationRepository {
  Future<void> sendInvitation({
    required String workspaceId,
    required String workspaceName,
    required String senderId,
    required String receiverEmail,
    required String role,
    required String department,
  });

  Future<void> acceptInvitation({
    required String invitationId,
    required String receiverUserId,
  });

  Future<void> rejectInvitation({required String invitationId});

  Future<List<EnterpriseInvitation>> getPendingInvitationsForEmail({
    required String email,
  });
}
