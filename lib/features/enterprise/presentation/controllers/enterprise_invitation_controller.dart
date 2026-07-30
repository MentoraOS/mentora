import 'package:flutter/foundation.dart';
import '../../../../application/authentication/authentication_session.dart';
import '../../../../application/workspace/workspace_state.dart';
import '../../domain/workflows/accept_enterprise_invitation_workflow.dart';
import '../../domain/entities/enterprise_invitation.dart';
import '../../domain/usecases/accept_enterprise_invitation_usecase.dart';
import '../../domain/usecases/get_pending_enterprise_invitation_usecase.dart';
import '../../domain/usecases/reject_enterprise_invitation_usecase.dart';
import '../../domain/usecases/send_enterprise_invitation_usecase.dart';
import '../../../../core/workflow/workflow_context.dart';
import '../../../../core/workflow/workflow_engine.dart';
import '../../domain/workflows/send_enterprise_invitation_workflow.dart';
import '../../domain/gateways/enterprise_gateway.dart';

class EnterpriseInvitationController extends ChangeNotifier {
  final SendEnterpriseInvitationUseCase sendInvitationUseCase;
  final AcceptEnterpriseInvitationUseCase acceptInvitationUseCase;
  final RejectEnterpriseInvitationUseCase rejectInvitationUseCase;
  final GetPendingEnterpriseInvitationsUseCase getPendingInvitationsUseCase;
  final EnterpriseGateway enterpriseGateway;
  final WorkspaceState workspaceState;
  final AuthenticationSession session;

  EnterpriseInvitationController({
    required this.sendInvitationUseCase,
    required this.acceptInvitationUseCase,
    required this.rejectInvitationUseCase,
    required this.getPendingInvitationsUseCase,
    required this.enterpriseGateway,
    required this.workspaceState,
    required this.session,
  });

  bool isLoading = false;
  String? error;
  List<EnterpriseInvitation> pendingInvitations = [];

  Future<void> sendInvitation({
    required String receiverEmail,
    required String role,
    required String department,
  }) async {
    final workspace = workspaceState.currentWorkspace;
    final senderId = session.currentUserId;

    if (workspace == null || senderId == null) {
      error = 'Workspace ou session introuvable';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await WorkflowEngine.execute<void>(
        workflow: SendEnterpriseInvitationWorkflow(
          sendInvitationUseCase: sendInvitationUseCase,
          receiverEmail: receiverEmail,
          role: role,
          department: department,
        ),
        context: WorkflowContext(
          userId: senderId,
          workspaceId: workspace.id,
          metadata: {'workspaceName': workspace.name},
        ),
      );

      if (result.isFailure) {
        error = result.message ?? 'Échec de l’invitation';
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadPendingInvitations() async {
    final email = session.currentEmail;

    print('CURRENT EMAIL = [$email]');

    if (email == null || email.trim().isEmpty) {
      error = 'Email utilisateur introuvable';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      pendingInvitations = await getPendingInvitationsUseCase(email: email);

      print('PENDING INVITATIONS = ${pendingInvitations.length}');
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> acceptInvitation(String invitationId) async {
    final userId = session.currentUserId;

    if (userId == null) {
      error = 'Utilisateur introuvable';
      notifyListeners();
      return;
    }

    final invitation = pendingInvitations.firstWhere(
      (item) => item.id == invitationId,
    );

    final result = await WorkflowEngine.execute<void>(
      workflow: AcceptEnterpriseInvitationWorkflow(
        enterpriseGateway: enterpriseGateway,
        invitationId: invitationId,
      ),
      context: WorkflowContext(
        userId: userId,
        workspaceId: workspaceState.currentWorkspace?.id,
      ),
    );

    if (result.isFailure) {
      error = result.message ?? 'Échec de l’acceptation';
    } else {
      await workspaceState.refresh();

      workspaceState.selectWorkspace(invitation.workspaceId);

      pendingInvitations.removeWhere((item) => item.id == invitationId);

      error = null;
    }

    notifyListeners();
  }

  Future<void> rejectInvitation(String invitationId) async {
    await rejectInvitationUseCase(invitationId: invitationId);
  }
}
