import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/workspace/default_workspace_state.dart';
import 'package:mentora/application/workspace/workspace_state.dart';
import 'package:mentora/application/workspace/workspace_state_projection.dart';
import 'package:mentora/domain/workspace/workspace_membership.dart';
import 'package:mentora/domain/workspace/workspace_repository.dart';
import 'package:mentora/domain/workspace/workspace_type.dart';
import 'package:mentora/presentation/controllers/workspace/workspace_controller.dart';

void main() {
  group('DefaultWorkspaceState', () {
    test('starts empty and unauthenticated', () {
      final state = _state(_FakeWorkspaceRepository());

      expect(state.status, WorkspaceStateStatus.unauthenticated);
      expect(state.currentWorkspace, isNull);
      expect(state.memberships, isEmpty);
    });

    test('loads memberships and selects personal deterministically', () async {
      final state = _state(
        _FakeWorkspaceRepository(memberships: const [_workspaceOne]),
      );

      await state.initialize(userId: 'user-1', userName: 'Ada');

      expect(state.memberships, hasLength(2));
      expect(state.currentWorkspace?.id, 'personal_user-1');
    });

    test('switching updates state through an injected controller', () async {
      final state = _state(
        _FakeWorkspaceRepository(memberships: const [_workspaceOne]),
      );
      await state.initialize(userId: 'user-1', userName: 'Ada');
      final controller = WorkspaceController(workspaceState: state);

      expect(controller.switchWorkspace('workspace-1'), isTrue);
      expect(controller.currentWorkspaceId, 'workspace-1');
    });

    test('refresh preserves a valid selection', () async {
      final repository = _FakeWorkspaceRepository(
        memberships: const [_workspaceOne],
      );
      final state = _state(repository);
      await state.initialize(userId: 'user-1', userName: 'Ada');
      state.selectWorkspace('workspace-1');

      await state.refresh();

      expect(state.currentWorkspace?.id, 'workspace-1');
    });

    test('refresh falls back when current membership disappears', () async {
      final repository = _FakeWorkspaceRepository(
        memberships: const [_workspaceOne],
      );
      final state = _state(repository);
      await state.initialize(userId: 'user-1', userName: 'Ada');
      state.selectWorkspace('workspace-1');
      repository.memberships = const [];

      await state.refresh();

      expect(state.currentWorkspace?.id, 'personal_user-1');
    });

    test('clear removes every previous user Workspace value', () async {
      final state = _state(
        _FakeWorkspaceRepository(memberships: const [_workspaceOne]),
      );
      await state.initialize(userId: 'user-1', userName: 'Ada');

      state.clear();

      expect(state.status, WorkspaceStateStatus.unauthenticated);
      expect(state.currentWorkspace, isNull);
      expect(state.currentMembership, isNull);
      expect(state.memberships, isEmpty);
    });

    test(
      'repository failure is explicit and leaves no valid-looking state',
      () async {
        final failure = StateError('workspace unavailable');
        final state = _state(_FakeWorkspaceRepository(error: failure));

        await expectLater(
          state.initialize(userId: 'user-1', userName: 'Ada'),
          throwsA(same(failure)),
        );

        expect(state.status, WorkspaceStateStatus.failure);
        expect(state.error, same(failure));
        expect(state.currentWorkspace, isNull);
        expect(state.memberships, isEmpty);
      },
    );

    test(
      'rejects malformed memberships instead of defaulting values',
      () async {
        final state = _state(
          _FakeWorkspaceRepository(
            memberships: const [
              WorkspaceMembership(
                workspaceId: '',
                workspaceType: WorkspaceType.company,
                workspaceName: 'Invalid',
                role: 'member',
              ),
            ],
          ),
        );

        await expectLater(
          state.initialize(userId: 'user-1', userName: 'Ada'),
          throwsFormatException,
        );
        expect(state.status, WorkspaceStateStatus.failure);
      },
    );
  });
}

DefaultWorkspaceState _state(WorkspaceRepository repository) {
  return DefaultWorkspaceState(
    repository: repository,
    projection: _FakeProjection(),
  );
}

const _workspaceOne = WorkspaceMembership(
  workspaceId: 'workspace-1',
  workspaceType: WorkspaceType.company,
  workspaceName: 'Mentora Company',
  role: 'member',
);

final class _FakeWorkspaceRepository implements WorkspaceRepository {
  _FakeWorkspaceRepository({this.memberships = const [], this.error});

  List<WorkspaceMembership> memberships;
  final Object? error;

  @override
  Future<List<WorkspaceMembership>> membershipsForUser(String userId) async {
    if (error != null) throw error!;
    return memberships;
  }
}

final class _FakeProjection implements WorkspaceStateProjection {
  @override
  void clear() {}

  @override
  void project({
    required String userId,
    required List<WorkspaceMembership> memberships,
    required String currentWorkspaceId,
  }) {}
}
