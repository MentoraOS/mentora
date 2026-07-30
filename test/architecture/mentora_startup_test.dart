import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/authentication/authentication_session_projection.dart';
import 'package:mentora/application/authentication/default_authentication_session.dart';
import 'package:mentora/application/startup/mentora_startup.dart';
import 'package:mentora/application/startup/startup_result.dart';
import 'package:mentora/application/workspace/default_workspace_state.dart';
import 'package:mentora/application/workspace/workspace_state.dart';
import 'package:mentora/application/workspace/workspace_state_projection.dart';
import 'package:mentora/domain/authentication/authentication_service.dart';
import 'package:mentora/domain/session/session_model.dart';
import 'package:mentora/domain/session/session_repository.dart';
import 'package:mentora/domain/workspace/workspace_membership.dart';
import 'package:mentora/domain/workspace/workspace_repository.dart';
import 'package:mentora/domain/workspace/workspace_type.dart';

void main() {
  group('MentoraStartup', () {
    test('returns unauthenticated without querying Workspace', () async {
      final workspaceRepository = _FakeWorkspaceRepository();
      final runtime = _runtime(
        sessionRepository: _FakeSessionRepository(session: null),
        workspaceRepository: workspaceRepository,
      );

      final result = await runtime.startup.execute();

      expect(result.status, StartupStatus.unauthenticated);
      expect(workspaceRepository.queryCount, 0);
      expect(runtime.session.isAuthenticated, isFalse);
      expect(runtime.workspaceState.currentWorkspace, isNull);
    });

    test('commits Session and Workspace when data is ready', () async {
      final runtime = _runtime(
        sessionRepository: _FakeSessionRepository(session: _session),
        workspaceRepository: _FakeWorkspaceRepository(
          memberships: const [_companyMembership],
        ),
      );

      final result = await runtime.startup.execute();

      expect(result.status, StartupStatus.ready);
      expect(runtime.session.current, same(_session));
      expect(runtime.session.isAuthenticated, isTrue);
      expect(runtime.workspaceState.currentWorkspace?.id, 'personal_user-1');
      expect(runtime.workspaceState.memberships, hasLength(2));
    });

    test('returns failure without exposing partially ready runtime', () async {
      final failure = StateError('Workspace unavailable');
      final runtime = _runtime(
        sessionRepository: _FakeSessionRepository(session: _session),
        workspaceRepository: _FakeWorkspaceRepository(error: failure),
      );

      final result = await runtime.startup.execute();

      expect(result.status, StartupStatus.failure);
      expect(result.error, same(failure));
      expect(runtime.session.status, AuthenticationSessionStatus.failure);
      expect(runtime.session.current, isNull);
      expect(runtime.workspaceState.memberships, isEmpty);
    });

    test('preserves personal Workspace without remote membership', () async {
      final runtime = _runtime(
        sessionRepository: _FakeSessionRepository(session: _session),
        workspaceRepository: _FakeWorkspaceRepository(),
      );

      final result = await runtime.startup.execute();

      expect(result.status, StartupStatus.ready);
      expect(runtime.workspaceState.memberships, hasLength(1));
      expect(
        runtime.workspaceState.memberships.single.workspaceType,
        WorkspaceType.personal,
      );
    });

    test('logout clears Session and Workspace deterministically', () async {
      final runtime = _runtime(
        sessionRepository: _FakeSessionRepository(session: _session),
        workspaceRepository: _FakeWorkspaceRepository(
          memberships: const [_companyMembership],
        ),
      );
      await runtime.startup.execute();

      await runtime.session.signOut();

      expect(runtime.session.isAuthenticated, isFalse);
      expect(
        runtime.session.status,
        AuthenticationSessionStatus.unauthenticated,
      );
      expect(runtime.workspaceState.currentWorkspace, isNull);
      expect(runtime.workspaceState.memberships, isEmpty);
    });
  });
}

({
  MentoraStartup startup,
  AuthenticationSession session,
  WorkspaceState workspaceState,
})
_runtime({
  required SessionRepository sessionRepository,
  required WorkspaceRepository workspaceRepository,
}) {
  final workspaceState = DefaultWorkspaceState(
    repository: workspaceRepository,
    projection: const _WorkspaceProjection(),
  );
  final session = DefaultAuthenticationSession(
    authenticationService: _FakeAuthenticationService(),
    sessionRepository: sessionRepository,
    workspaceState: workspaceState,
    projection: const _AuthenticationProjection(),
  );

  return (
    startup: MentoraStartup(session: session),
    session: session,
    workspaceState: workspaceState,
  );
}

const _session = SessionModel(
  id: 'user-1',
  email: 'user@mentora.test',
  name: 'Ada Mentor',
  photoUrl: '',
  countryCode: 'ML',
  currency: 'XOF',
  language: 'fr',
  roles: ['client'],
  permissions: [],
  isActive: true,
  isVerified: true,
  isPremium: false,
);

const _companyMembership = WorkspaceMembership(
  workspaceId: 'workspace-1',
  workspaceType: WorkspaceType.company,
  workspaceName: 'Mentora Company',
  role: 'member',
);

final class _FakeSessionRepository implements SessionRepository {
  const _FakeSessionRepository({required this.session});

  final SessionModel? session;

  @override
  Future<SessionModel?> fetchCurrentSession() async => session;

  @override
  Future<void> signOut() async {}
}

final class _FakeWorkspaceRepository implements WorkspaceRepository {
  _FakeWorkspaceRepository({this.memberships = const [], this.error});

  final List<WorkspaceMembership> memberships;
  final Object? error;
  int queryCount = 0;

  @override
  Future<List<WorkspaceMembership>> membershipsForUser(String userId) async {
    queryCount++;
    if (error != null) throw error!;
    return memberships;
  }
}

final class _FakeAuthenticationService implements AuthenticationService {
  @override
  Future<String> registerClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return 'user-1';
  }

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    return 'user-1';
  }

  @override
  Future<void> signOut() async {}
}

final class _AuthenticationProjection
    implements AuthenticationSessionProjection {
  const _AuthenticationProjection();

  @override
  void clear() {}

  @override
  void project(SessionModel session) {}
}

final class _WorkspaceProjection implements WorkspaceStateProjection {
  const _WorkspaceProjection();

  @override
  void clear() {}

  @override
  void project({
    required String userId,
    required List<WorkspaceMembership> memberships,
    required String currentWorkspaceId,
  }) {}
}
