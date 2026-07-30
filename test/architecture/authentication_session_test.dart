import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/authentication/authentication_session_projection.dart';
import 'package:mentora/application/authentication/default_authentication_session.dart';
import 'package:mentora/application/workspace/workspace_state.dart';
import 'package:mentora/domain/authentication/authentication_service.dart';
import 'package:mentora/domain/session/session_model.dart';
import 'package:mentora/domain/session/session_repository.dart';
import 'package:mentora/domain/workspace/workspace_membership.dart';
import 'package:mentora/domain/workspace/workspace_model.dart';

void main() {
  group('DefaultAuthenticationSession', () {
    test('initializes an authenticated session and Workspace', () async {
      final workspace = _FakeWorkspaceState();
      final session = _session(
        repository: _FakeSessionRepository(current: _model),
        workspace: workspace,
      );

      await session.initialize();

      expect(session.status, AuthenticationSessionStatus.authenticated);
      expect(session.current, same(_model));
      expect(workspace.initializedUserId, _model.id);
    });

    test('initializes an unauthenticated session safely', () async {
      final workspace = _FakeWorkspaceState();
      final session = _session(
        repository: _FakeSessionRepository(current: null),
        workspace: workspace,
      );

      await session.initialize();

      expect(session.status, AuthenticationSessionStatus.unauthenticated);
      expect(session.current, isNull);
      expect(workspace.clearCount, 1);
    });

    test('sign in transitions through the Application boundary', () async {
      final repository = _FakeSessionRepository(current: null);
      final authentication = _FakeAuthenticationService(
        onSignIn: () => repository.current = _model,
      );
      final session = _session(
        authentication: authentication,
        repository: repository,
        workspace: _FakeWorkspaceState(),
      );

      await session.signIn(email: _model.email, password: 'secret');

      expect(authentication.signInCount, 1);
      expect(session.isAuthenticated, isTrue);
      expect(session.currentUserId, _model.id);
    });

    test(
      'logout clears Session and Workspace even when adapter fails',
      () async {
        final failure = StateError('sign out failed');
        final workspace = _FakeWorkspaceState();
        final session = _session(
          authentication: _FakeAuthenticationService(signOutError: failure),
          repository: _FakeSessionRepository(current: _model),
          workspace: workspace,
        );
        await session.initialize();

        await expectLater(session.signOut(), throwsA(same(failure)));

        expect(session.status, AuthenticationSessionStatus.unauthenticated);
        expect(session.current, isNull);
        expect(workspace.clearCount, greaterThanOrEqualTo(1));
      },
    );

    test(
      'authentication failure is explicit and clears runtime state',
      () async {
        final failure = StateError('invalid credentials');
        final workspace = _FakeWorkspaceState();
        final session = _session(
          authentication: _FakeAuthenticationService(signInError: failure),
          repository: _FakeSessionRepository(current: null),
          workspace: workspace,
        );

        await expectLater(
          session.signIn(email: _model.email, password: 'wrong'),
          throwsA(same(failure)),
        );

        expect(session.status, AuthenticationSessionStatus.failure);
        expect(session.error, same(failure));
        expect(session.current, isNull);
        expect(workspace.clearCount, 1);
      },
    );
  });
}

DefaultAuthenticationSession _session({
  _FakeAuthenticationService? authentication,
  required _FakeSessionRepository repository,
  required WorkspaceState workspace,
}) {
  return DefaultAuthenticationSession(
    authenticationService: authentication ?? _FakeAuthenticationService(),
    sessionRepository: repository,
    workspaceState: workspace,
    projection: const _FakeProjection(),
  );
}

const _model = SessionModel(
  id: 'user-1',
  email: 'user@mentora.test',
  name: 'Ada Mentor',
  photoUrl: '',
  countryCode: 'ML',
  currency: 'XOF',
  language: 'fr',
  roles: ['client'],
  permissions: ['profile.read'],
  isActive: true,
  isVerified: true,
  isPremium: false,
);

final class _FakeSessionRepository implements SessionRepository {
  _FakeSessionRepository({required this.current});

  SessionModel? current;

  @override
  Future<SessionModel?> fetchCurrentSession() async => current;

  @override
  Future<void> signOut() async {}
}

final class _FakeAuthenticationService implements AuthenticationService {
  _FakeAuthenticationService({
    this.onSignIn,
    this.signInError,
    this.signOutError,
  });

  final void Function()? onSignIn;
  final Object? signInError;
  final Object? signOutError;
  int signInCount = 0;

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    signInCount++;
    if (signInError != null) throw signInError!;
    onSignIn?.call();
    return _model.id;
  }

  @override
  Future<void> signOut() async {
    if (signOutError != null) throw signOutError!;
  }

  @override
  Future<String> registerClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _model.id;
  }
}

final class _FakeProjection implements AuthenticationSessionProjection {
  const _FakeProjection();

  @override
  void clear() {}

  @override
  void project(SessionModel session) {}
}

final class _FakeWorkspaceState implements WorkspaceState {
  int clearCount = 0;
  String? initializedUserId;

  @override
  WorkspaceModel? get currentWorkspace => null;

  @override
  WorkspaceMembership? get currentMembership => null;

  @override
  Object? get error => null;

  @override
  List<WorkspaceMembership> get memberships => const [];

  @override
  WorkspaceStateStatus get status => WorkspaceStateStatus.unauthenticated;

  @override
  void addListener(WorkspaceStateListener listener) {}

  @override
  void clear() {
    clearCount++;
    initializedUserId = null;
  }

  @override
  Future<void> initialize({
    required String userId,
    required String userName,
  }) async {
    initializedUserId = userId;
  }

  @override
  Future<void> refresh() async {}

  @override
  void removeListener(WorkspaceStateListener listener) {}

  @override
  bool selectWorkspace(String workspaceId) => false;
}
