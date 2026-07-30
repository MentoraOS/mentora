import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/workspace/workspace_state.dart';
import 'package:mentora/domain/session/session_model.dart';
import 'package:mentora/domain/workspace/workspace_membership.dart';
import 'package:mentora/domain/workspace/workspace_model.dart';
import 'package:mentora/domain/workspace/workspace_type.dart';
import 'package:mentora/features/enterprise/domain/entities/enterprise_invitation.dart';
import 'package:mentora/features/enterprise/domain/gateways/enterprise_gateway.dart';
import 'package:mentora/features/enterprise/domain/repositories/enterprise_invitation_repository.dart';
import 'package:mentora/features/enterprise/domain/usecases/accept_enterprise_invitation_usecase.dart';
import 'package:mentora/features/enterprise/domain/usecases/get_pending_enterprise_invitation_usecase.dart';
import 'package:mentora/features/enterprise/domain/usecases/reject_enterprise_invitation_usecase.dart';
import 'package:mentora/features/enterprise/domain/usecases/send_enterprise_invitation_usecase.dart';
import 'package:mentora/features/enterprise/presentation/controllers/enterprise_invitation_controller.dart';

void main() {
  group('Enterprise invitation Workspace refresh', () {
    test('uses the injected refresh port before switching Workspace', () async {
      final events = <String>[];
      final controller = _controller(
        gateway: _FakeEnterpriseGateway(events: events),
        workspaceState: _FakeWorkspaceState(events: events),
      );
      controller.pendingInvitations = [_invitation];

      await controller.acceptInvitation(_invitation.id);

      expect(events, ['accept', 'refresh']);
      expect(
        controller.workspaceState.currentWorkspace?.id,
        _invitation.workspaceId,
      );
      expect(controller.pendingInvitations, isEmpty);
      expect(controller.error, isNull);
    });

    test(
      'does not refresh or mutate pending state after gateway failure',
      () async {
        final events = <String>[];
        final controller = _controller(
          gateway: _FakeEnterpriseGateway(events: events, shouldFail: true),
          workspaceState: _FakeWorkspaceState(events: events),
        );
        controller.pendingInvitations = [_invitation];

        await controller.acceptInvitation(_invitation.id);

        expect(events, ['accept']);
        expect(controller.workspaceState.currentWorkspace?.id, isNull);
        expect(controller.pendingInvitations, const [_invitation]);
        expect(controller.error, isNotNull);
      },
    );
  });
}

EnterpriseInvitationController _controller({
  required EnterpriseGateway gateway,
  required WorkspaceState workspaceState,
}) {
  final repository = _FakeInvitationRepository();

  return EnterpriseInvitationController(
    sendInvitationUseCase: SendEnterpriseInvitationUseCase(repository),
    acceptInvitationUseCase: AcceptEnterpriseInvitationUseCase(repository),
    rejectInvitationUseCase: RejectEnterpriseInvitationUseCase(repository),
    getPendingInvitationsUseCase: GetPendingEnterpriseInvitationsUseCase(
      repository,
    ),
    enterpriseGateway: gateway,
    workspaceState: workspaceState,
    session: _FakeAuthenticationSession(),
  );
}

const _session = SessionModel(
  id: 'user-1',
  email: 'user@example.com',
  name: 'Mentora User',
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

const _invitation = EnterpriseInvitation(
  id: 'invitation-1',
  workspaceId: 'workspace-1',
  workspaceName: 'Mentora Enterprise',
  senderId: 'owner-1',
  receiverEmail: 'user@example.com',
  role: 'member',
  department: 'engineering',
  status: 'pending',
);

final class _FakeEnterpriseGateway implements EnterpriseGateway {
  _FakeEnterpriseGateway({required this.events, this.shouldFail = false});

  final List<String> events;
  final bool shouldFail;

  @override
  Future<void> acceptInvitation({
    required String invitationId,
    required String receiverUserId,
  }) async {
    events.add('accept');
    if (shouldFail) {
      throw StateError('accept failed');
    }
  }
}

final class _FakeAuthenticationSession implements AuthenticationSession {
  @override
  SessionModel? get current => _session;

  @override
  String? get currentEmail => _session.email;

  @override
  String get currentName => _session.name;

  @override
  List<String> get currentPermissions => _session.permissions;

  @override
  List<String> get currentRoles => _session.roles;

  @override
  String? get currentUserId => _session.id;

  @override
  Object? get error => null;

  @override
  bool get isActive => true;

  @override
  bool get isAdmin => false;

  @override
  bool get isAuthenticated => true;

  @override
  bool get isClient => true;

  @override
  bool get isExpert => false;

  @override
  AuthenticationSessionStatus get status =>
      AuthenticationSessionStatus.authenticated;

  @override
  void addListener(AuthenticationSessionListener listener) {}

  @override
  Future<void> initialize() async {}

  @override
  Future<String> registerClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _session.id;
  }

  @override
  void removeListener(AuthenticationSessionListener listener) {}

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}
}

final class _FakeWorkspaceState implements WorkspaceState {
  _FakeWorkspaceState({required this.events});

  final List<String> events;
  final List<WorkspaceStateListener> _listeners = [];
  List<WorkspaceMembership> _memberships = const [];
  String? _currentId;

  @override
  WorkspaceModel? get currentWorkspace {
    final membership = currentMembership;
    return membership == null
        ? null
        : WorkspaceModel(
            id: membership.workspaceId,
            type: membership.workspaceType,
            name: membership.workspaceName,
            role: membership.role,
            permissions: membership.permissions,
          );
  }

  @override
  WorkspaceMembership? get currentMembership {
    for (final membership in _memberships) {
      if (membership.workspaceId == _currentId) return membership;
    }
    return null;
  }

  @override
  List<WorkspaceMembership> get memberships => _memberships;

  @override
  WorkspaceStateStatus get status => WorkspaceStateStatus.ready;

  @override
  Object? get error => null;

  @override
  Future<void> refresh() async {
    events.add('refresh');
    _memberships = [
      const WorkspaceMembership(
        workspaceId: 'workspace-1',
        workspaceType: WorkspaceType.company,
        workspaceName: 'Mentora Enterprise',
        role: 'member',
      ),
    ];
  }

  @override
  bool selectWorkspace(String workspaceId) {
    if (!_memberships.any((item) => item.workspaceId == workspaceId)) {
      return false;
    }
    _currentId = workspaceId;
    return true;
  }

  @override
  void addListener(WorkspaceStateListener listener) {
    _listeners.add(listener);
  }

  @override
  void clear() {
    _memberships = const [];
    _currentId = null;
  }

  @override
  Future<void> initialize({
    required String userId,
    required String userName,
  }) async {}

  @override
  void removeListener(WorkspaceStateListener listener) {
    _listeners.remove(listener);
  }
}

final class _FakeInvitationRepository
    implements EnterpriseInvitationRepository {
  @override
  Future<void> acceptInvitation({
    required String invitationId,
    required String receiverUserId,
  }) async {}

  @override
  Future<List<EnterpriseInvitation>> getPendingInvitationsForEmail({
    required String email,
  }) async {
    return const [];
  }

  @override
  Future<void> rejectInvitation({required String invitationId}) async {}

  @override
  Future<void> sendInvitation({
    required String workspaceId,
    required String workspaceName,
    required String senderId,
    required String receiverEmail,
    required String role,
    required String department,
  }) async {}
}
