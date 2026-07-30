enum AuthenticationFailureCode {
  emailAlreadyInUse,
  weakPassword,
  invalidEmail,
  userNotFound,
  wrongPassword,
  invalidCredential,
  unknown,
}

final class AuthenticationFailure implements Exception {
  const AuthenticationFailure({required this.code, this.message});

  final AuthenticationFailureCode code;
  final String? message;

  @override
  String toString() {
    return message ?? code.name;
  }
}
