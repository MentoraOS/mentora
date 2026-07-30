import 'package:flutter/foundation.dart';

import '../../../../application/workspace/workspace_state.dart';
import '../../domain/entities/enterprise_member.dart';
import '../../domain/usecases/get_enterprise_members_usecase.dart';
import '../../domain/usecases/invite_enterprise_member_usecase.dart';
import '../../domain/usecases/remove_enterprise_member_usecase.dart';
import '../../domain/usecases/update_enterprise_member_role_usecase.dart';

class EnterpriseMemberController extends ChangeNotifier {
  final GetEnterpriseMembersUseCase getMembersUseCase;
  final InviteEnterpriseMemberUseCase inviteMemberUseCase;
  final RemoveEnterpriseMemberUseCase removeMemberUseCase;
  final UpdateEnterpriseMemberRoleUseCase updateMemberRoleUseCase;
  final WorkspaceState workspaceState;

  EnterpriseMemberController({
    required this.getMembersUseCase,
    required this.inviteMemberUseCase,
    required this.removeMemberUseCase,
    required this.updateMemberRoleUseCase,
    required this.workspaceState,
  });

  bool isLoading = false;
  String? error;
  List<EnterpriseMember> members = [];

  Future<void> loadMembers() async {
    final workspaceId = workspaceState.currentWorkspace?.id;

    if (workspaceId == null) {
      error = 'Aucun workspace actif';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      members = await getMembersUseCase(workspaceId: workspaceId);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
