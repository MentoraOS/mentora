abstract class EnterpriseGateway {
  Future<void> acceptInvitation({
    required String invitationId,
    required String receiverUserId,
  });
}
