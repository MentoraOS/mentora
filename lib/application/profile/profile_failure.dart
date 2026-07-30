sealed class ProfileFailure implements Exception {
  const ProfileFailure();
}

final class ProfileUnauthenticatedFailure extends ProfileFailure {
  const ProfileUnauthenticatedFailure();
}

final class ProfileNotFoundFailure extends ProfileFailure {
  const ProfileNotFoundFailure();
}

final class ProfileInfrastructureFailure extends ProfileFailure {
  const ProfileInfrastructureFailure({required this.cause});

  final Object cause;
}
