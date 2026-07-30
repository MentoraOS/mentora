final class Profile {
  const Profile({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
}
