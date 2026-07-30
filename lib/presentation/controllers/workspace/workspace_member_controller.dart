import 'package:flutter/foundation.dart';

import '../../../application/workspace/workspace_state.dart';
import '../../../domain/workspace/workspace_member.dart';
import '../../../domain/workspace/workspace_member_repository.dart';

class WorkspaceMemberController extends ChangeNotifier {
  final WorkspaceMemberRepository repository;
  final WorkspaceState workspaceState;

  WorkspaceMemberController({
    required this.repository,
    required this.workspaceState,
  });

  bool isLoading = false;
  String? error;
  List<WorkspaceMember> members = [];

  Future<void> loadCurrentWorkspaceMembers() async {
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
      members = await repository.loadMembers(workspaceId);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
