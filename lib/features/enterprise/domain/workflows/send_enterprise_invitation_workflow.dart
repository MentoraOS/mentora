import '../../../../core/workflow/workflow.dart';
import '../../../../core/workflow/workflow_context.dart';
import '../../../../core/workflow/workflow_result.dart';
import '../usecases/send_enterprise_invitation_usecase.dart';

class SendEnterpriseInvitationWorkflow extends Workflow<void> {
  final SendEnterpriseInvitationUseCase sendInvitationUseCase;

  final String receiverEmail;
  final String role;
  final String department;

  const SendEnterpriseInvitationWorkflow({
    required this.sendInvitationUseCase,
    required this.receiverEmail,
    required this.role,
    required this.department,
  });

  @override
  String get name => 'enterprise.send_invitation';

  @override
  Future<WorkflowResult<void>> execute(WorkflowContext context) async {
    final workspaceId = context.workspaceId;
    final senderId = context.userId;
    final workspaceName = context.get<String>('workspaceName');

    if (workspaceId == null || senderId == null || workspaceName == null) {
      return WorkflowResult.failure(message: 'Contexte workflow invalide');
    }

    if (receiverEmail.trim().isEmpty || !receiverEmail.contains('@')) {
      return WorkflowResult.failure(message: 'Email invalide');
    }

    await sendInvitationUseCase(
      workspaceId: workspaceId,
      workspaceName: workspaceName,
      senderId: senderId,
      receiverEmail: receiverEmail,
      role: role,
      department: department,
    );

    return WorkflowResult.success(message: 'Invitation envoyée');
  }
}
