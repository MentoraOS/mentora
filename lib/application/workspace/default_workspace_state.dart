import '../../domain/workspace/workspace_membership.dart';
import '../../domain/workspace/workspace_model.dart';
import '../../domain/workspace/workspace_repository.dart';
import '../../domain/workspace/workspace_type.dart';
import 'workspace_state.dart';
import 'workspace_state_projection.dart';

final class DefaultWorkspaceState implements WorkspaceState {
  DefaultWorkspaceState({
    required WorkspaceRepository repository,
    required WorkspaceStateProjection projection,
  }) : _repository = repository,
       _projection = projection;

  final WorkspaceRepository _repository;
  final WorkspaceStateProjection _projection;
  final Set<WorkspaceStateListener> _listeners = {};

  WorkspaceStateStatus _status = WorkspaceStateStatus.unauthenticated;
  Object? _error;
  String? _userId;
  String? _userName;
  String? _currentWorkspaceId;
  List<WorkspaceMembership> _memberships = const [];

  @override
  WorkspaceStateStatus get status => _status;

  @override
  Object? get error => _error;

  @override
  List<WorkspaceMembership> get memberships => List.unmodifiable(_memberships);

  @override
  WorkspaceMembership? get currentMembership {
    final currentId = _currentWorkspaceId;
    if (currentId == null) {
      return null;
    }

    for (final membership in _memberships) {
      if (membership.workspaceId == currentId) {
        return membership;
      }
    }
    return null;
  }

  @override
  WorkspaceModel? get currentWorkspace {
    final membership = currentMembership;
    if (membership == null) {
      return null;
    }

    return WorkspaceModel(
      id: membership.workspaceId,
      type: membership.workspaceType,
      name: membership.workspaceName,
      organizationId: membership.organizationId,
      departmentId: membership.departmentId,
      role: membership.role,
      permissions: membership.permissions,
    );
  }

  @override
  Future<void> initialize({
    required String userId,
    required String userName,
  }) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'must not be empty');
    }

    _userId = userId;
    _userName = userName;
    await _load(preserveSelection: false);
  }

  @override
  Future<void> refresh() async {
    if (_userId == null) {
      clear();
      return;
    }

    await _load(preserveSelection: true);
  }

  Future<void> _load({required bool preserveSelection}) async {
    final userId = _userId!;
    final previousSelection = preserveSelection ? _currentWorkspaceId : null;

    _status = WorkspaceStateStatus.loading;
    _error = null;
    _notifyListeners();

    try {
      final remoteMemberships = await _repository.membershipsForUser(userId);
      for (final membership in remoteMemberships) {
        _validate(membership);
      }

      final personal = WorkspaceMembership(
        workspaceId: 'personal_$userId',
        workspaceType: WorkspaceType.personal,
        workspaceName: (_userName?.trim().isNotEmpty ?? false)
            ? _userName!.trim()
            : 'Personnel',
        role: 'owner',
      );
      final nextMemberships = <WorkspaceMembership>[
        personal,
        ...remoteMemberships.where(
          (membership) => membership.workspaceId != personal.workspaceId,
        ),
      ];
      final canPreserve =
          previousSelection != null &&
          nextMemberships.any(
            (membership) => membership.workspaceId == previousSelection,
          );

      _memberships = List.unmodifiable(nextMemberships);
      _currentWorkspaceId = canPreserve
          ? previousSelection
          : personal.workspaceId;
      _status = WorkspaceStateStatus.ready;
      _error = null;
      _project();
      _notifyListeners();
    } catch (error) {
      _memberships = const [];
      _currentWorkspaceId = null;
      _status = WorkspaceStateStatus.failure;
      _error = error;
      _projection.clear();
      _notifyListeners();
      rethrow;
    }
  }

  void _validate(WorkspaceMembership membership) {
    if (membership.workspaceId.trim().isEmpty ||
        membership.workspaceName.trim().isEmpty ||
        membership.role.trim().isEmpty) {
      throw FormatException(
        'Malformed Workspace membership: ${membership.workspaceId}',
      );
    }
  }

  @override
  bool selectWorkspace(String workspaceId) {
    if (_status != WorkspaceStateStatus.ready ||
        !_memberships.any(
          (membership) => membership.workspaceId == workspaceId,
        )) {
      return false;
    }

    if (_currentWorkspaceId == workspaceId) {
      return true;
    }

    _currentWorkspaceId = workspaceId;
    _project();
    _notifyListeners();
    return true;
  }

  void _project() {
    _projection.project(
      userId: _userId!,
      memberships: _memberships,
      currentWorkspaceId: _currentWorkspaceId!,
    );
  }

  @override
  void clear() {
    _userId = null;
    _userName = null;
    _memberships = const [];
    _currentWorkspaceId = null;
    _status = WorkspaceStateStatus.unauthenticated;
    _error = null;
    _projection.clear();
    _notifyListeners();
  }

  @override
  void addListener(WorkspaceStateListener listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(WorkspaceStateListener listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List<WorkspaceStateListener>.of(_listeners)) {
      listener();
    }
  }
}
