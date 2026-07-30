import 'profile.dart';

abstract interface class ProfileRepository {
  Future<Profile?> findByUserId(String userId);

  Stream<Profile?> observeByUserId(String userId);

  Future<void> update({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
  });
}

final class ProfileRepositoryException implements Exception {
  const ProfileRepositoryException({required this.cause});

  final Object cause;
}
