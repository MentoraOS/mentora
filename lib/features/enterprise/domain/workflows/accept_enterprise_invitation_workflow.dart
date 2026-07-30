import '../../../../core/workflow/workflow.dart';
import '../../../../core/workflow/workflow_context.dart';
import '../../../../core/workflow/workflow_result.dart';
import '../gateways/enterprise_gateway.dart';

class AcceptEnterpriseInvitationWorkflow extends Workflow<void> {
  final EnterpriseGateway enterpriseGateway;
  final String invitationId;

  const AcceptEnterpriseInvitationWorkflow({
    required this.enterpriseGateway,
    required this.invitationId,
  });

  @override
  String get name => 'enterprise.accept_invitation';

  @override
  Future<WorkflowResult<void>> execute(WorkflowContext context) async {
    final receiverUserId = context.userId;

    if (receiverUserId == null || receiverUserId.isEmpty) {
      return WorkflowResult.failure(message: 'Utilisateur introuvable');
    }

    if (invitationId.trim().isEmpty) {
      return WorkflowResult.failure(message: 'Invitation introuvable');
    }

    await enterpriseGateway.acceptInvitation(
      invitationId: invitationId,
      receiverUserId: receiverUserId,
    );

    return WorkflowResult.success(message: 'Invitation acceptée');
  }
}
