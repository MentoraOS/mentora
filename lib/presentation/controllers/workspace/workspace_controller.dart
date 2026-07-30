import 'package:flutter/foundation.dart';

import '../../../application/workspace/workspace_state.dart';
import '../../../domain/workspace/workspace_membership.dart';

class WorkspaceController extends ChangeNotifier {
  WorkspaceController({required WorkspaceState workspaceState})
    : _workspaceState = workspaceState {
    _workspaceState.addListener(notifyListeners);
  }

  final WorkspaceState _workspaceState;

  List<WorkspaceMembership> get memberships => _workspaceState.memberships;

  bool get hasMultipleWorkspaces => _workspaceState.memberships.length > 1;

  String? get currentWorkspaceId => _workspaceState.currentWorkspace?.id;

  bool switchWorkspace(String workspaceId) {
    return _workspaceState.selectWorkspace(workspaceId);
  }

  @override
  void dispose() {
    _workspaceState.removeListener(notifyListeners);
    super.dispose();
  }
}
