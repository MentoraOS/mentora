import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../application/workspace/workspace_state.dart';
import '../../../application/authentication/authentication_session.dart';
import '../../../features/enterprise/data/repositories/firestore_enterprise_member_repository.dart';
import '../../../features/enterprise/domain/usecases/get_enterprise_members_usecase.dart';
import '../../../features/enterprise/domain/usecases/invite_enterprise_member_usecase.dart';
import '../../../features/enterprise/domain/usecases/remove_enterprise_member_usecase.dart';
import '../../../features/enterprise/domain/usecases/update_enterprise_member_role_usecase.dart';
import '../../../features/enterprise/presentation/controllers/enterprise_member_controller.dart';
import '../../../features/enterprise/data/repositories/firestore_enterprise_invitation_repository.dart';

import '../../../features/enterprise/domain/usecases/send_enterprise_invitation_usecase.dart';
import '../../../features/enterprise/domain/usecases/accept_enterprise_invitation_usecase.dart';
import '../../../features/enterprise/domain/usecases/reject_enterprise_invitation_usecase.dart';
import '../../../features/enterprise/domain/usecases/get_pending_enterprise_invitation_usecase.dart';
import '../../../features/enterprise/presentation/controllers/enterprise_invitation_controller.dart';
import '../../../features/enterprise/data/gateways/firestore_enterprise_gateway.dart';

class EnterpriseModule {
  EnterpriseModule._();

  static final invitationRepository = FirestoreEnterpriseInvitationRepository(
    firestore: FirebaseFirestore.instance,
  );

  static final sendInvitation = SendEnterpriseInvitationUseCase(
    invitationRepository,
  );

  static final acceptInvitation = AcceptEnterpriseInvitationUseCase(
    invitationRepository,
  );

  static final enterpriseGateway = FirestoreEnterpriseGateway(
    firestore: FirebaseFirestore.instance,
  );

  static final rejectInvitation = RejectEnterpriseInvitationUseCase(
    invitationRepository,
  );

  static final getPendingInvitations = GetPendingEnterpriseInvitationsUseCase(
    invitationRepository,
  );

  static final memberRepository = FirestoreEnterpriseMemberRepository(
    firestore: FirebaseFirestore.instance,
  );

  static final getMembers = GetEnterpriseMembersUseCase(memberRepository);

  static final inviteMember = InviteEnterpriseMemberUseCase(memberRepository);

  static final removeMember = RemoveEnterpriseMemberUseCase(memberRepository);

  static final updateMemberRole = UpdateEnterpriseMemberRoleUseCase(
    memberRepository,
  );

  static EnterpriseMemberController createMemberController({
    required WorkspaceState workspaceState,
  }) {
    return EnterpriseMemberController(
      getMembersUseCase: getMembers,
      inviteMemberUseCase: inviteMember,
      removeMemberUseCase: removeMember,
      updateMemberRoleUseCase: updateMemberRole,
      workspaceState: workspaceState,
    );
  }

  static EnterpriseInvitationController createInvitationController({
    required WorkspaceState workspaceState,
    required AuthenticationSession session,
  }) {
    return EnterpriseInvitationController(
      sendInvitationUseCase: sendInvitation,
      acceptInvitationUseCase: acceptInvitation,
      rejectInvitationUseCase: rejectInvitation,
      getPendingInvitationsUseCase: getPendingInvitations,
      enterpriseGateway: enterpriseGateway,
      workspaceState: workspaceState,
      session: session,
    );
  }
}
