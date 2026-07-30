import '../../domain/authentication/authentication_service.dart';
import '../../domain/session/session_model.dart';
import '../../domain/session/session_repository.dart';
import '../workspace/workspace_state.dart';
import 'authentication_session.dart';
import 'authentication_session_projection.dart';

final class DefaultAuthenticationSession implements AuthenticationSession {
  DefaultAuthenticationSession({
    required AuthenticationService authenticationService,
    required SessionRepository sessionRepository,
    required WorkspaceState workspaceState,
    required AuthenticationSessionProjection projection,
  }) : _authenticationService = authenticationService,
       _sessionRepository = sessionRepository,
       _workspaceState = workspaceState,
       _projection = projection;

  final AuthenticationService _authenticationService;
  final SessionRepository _sessionRepository;
  final WorkspaceState _workspaceState;
  final AuthenticationSessionProjection _projection;
  final Set<AuthenticationSessionListener> _listeners = {};

  AuthenticationSessionStatus _status =
      AuthenticationSessionStatus.unauthenticated;
  SessionModel? _current;
  Object? _error;

  @override
  AuthenticationSessionStatus get status => _status;

  @override
  SessionModel? get current => _current;

  @override
  Object? get error => _error;

  @override
  bool get isAuthenticated =>
      _status == AuthenticationSessionStatus.authenticated && _current != null;

  @override
  String? get currentUserId => _current?.id;

  @override
  String? get currentEmail => _current?.email;

  @override
  String get currentName => _current?.name ?? '';

  @override
  List<String> get currentRoles => _current?.roles ?? const [];

  @override
  List<String> get currentPermissions => _current?.permissions ?? const [];

  @override
  bool get isActive => _current?.isActive ?? false;

  @override
  bool get isAdmin => currentRoles.contains('admin');

  @override
  bool get isExpert => currentRoles.contains('expert');

  @override
  bool get isClient => currentRoles.contains('client');

  @override
  Future<void> initialize() async {
    _status = AuthenticationSessionStatus.loading;
    _error = null;
    _notifyListeners();

    try {
      final session = await _sessionRepository.fetchCurrentSession();

      if (session == null) {
        _clearRuntime();
        return;
      }

      _current = session;
      _projection.project(session);
      await _workspaceState.initialize(
        userId: session.id,
        userName: session.name,
      );
      _status = AuthenticationSessionStatus.authenticated;
      _error = null;
      _notifyListeners();
    } catch (error) {
      _clearRuntime();
      _status = AuthenticationSessionStatus.failure;
      _error = error;
      _notifyListeners();
      rethrow;
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _authenticationService.signIn(email: email, password: password);
      await initialize();

      if (!isAuthenticated) {
        throw StateError(
          'Authentication succeeded without an application session.',
        );
      }
    } catch (error) {
      if (_status != AuthenticationSessionStatus.failure) {
        _clearRuntime();
        _status = AuthenticationSessionStatus.failure;
        _error = error;
        _notifyListeners();
      }
      rethrow;
    }
  }

  @override
  Future<String> registerClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) {
    return _authenticationService.registerClient(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    try {
      await _authenticationService.signOut();
    } finally {
      _clearRuntime();
    }
  }

  void _clearRuntime() {
    _current = null;
    _status = AuthenticationSessionStatus.unauthenticated;
    _error = null;
    _workspaceState.clear();
    _projection.clear();
    _notifyListeners();
  }

  @override
  void addListener(AuthenticationSessionListener listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(AuthenticationSessionListener listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List<AuthenticationSessionListener>.of(_listeners)) {
      listener();
    }
  }
}
