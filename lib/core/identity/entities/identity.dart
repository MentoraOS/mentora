class Identity {
  final String id;

  final String email;

  final String firstName;

  final String lastName;

  final bool verified;

  const Identity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.verified,
  });

  String get fullName => '$firstName $lastName';
}
