import '../../domain/workspace/workspace_membership.dart';
import '../../domain/workspace/workspace_model.dart';

enum WorkspaceStateStatus { unauthenticated, loading, ready, failure }

typedef WorkspaceStateListener = void Function();

abstract interface class WorkspaceState {
  WorkspaceStateStatus get status;
  Object? get error;
  WorkspaceModel? get currentWorkspace;
  WorkspaceMembership? get currentMembership;
  List<WorkspaceMembership> get memberships;

  Future<void> initialize({required String userId, required String userName});

  Future<void> refresh();

  bool selectWorkspace(String workspaceId);

  void clear();

  void addListener(WorkspaceStateListener listener);

  void removeListener(WorkspaceStateListener listener);
}
