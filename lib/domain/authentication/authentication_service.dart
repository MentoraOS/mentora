abstract interface class AuthenticationService {
  Future<String> registerClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  });

  Future<String> signIn({required String email, required String password});

  Future<void> signOut();
}
