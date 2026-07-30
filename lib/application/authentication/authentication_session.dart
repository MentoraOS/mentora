import '../../domain/session/session_model.dart';

enum AuthenticationSessionStatus {
  unauthenticated,
  loading,
  authenticated,
  failure,
}

typedef AuthenticationSessionListener = void Function();

abstract interface class AuthenticationSession {
  AuthenticationSessionStatus get status;
  SessionModel? get current;
  Object? get error;

  bool get isAuthenticated;
  String? get currentUserId;
  String? get currentEmail;
  String get currentName;
  List<String> get currentRoles;
  List<String> get currentPermissions;
  bool get isActive;
  bool get isAdmin;
  bool get isExpert;
  bool get isClient;

  Future<void> initialize();

  Future<void> signIn({required String email, required String password});

  Future<String> registerClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> signOut();

  void addListener(AuthenticationSessionListener listener);

  void removeListener(AuthenticationSessionListener listener);
}
