class Account {
  final String id;
  final String email;
  final String phone;
  final String displayName;
  final String photoUrl;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime createdAt;

  const Account({
    required this.id,
    required this.email,
    required this.phone,
    required this.displayName,
    required this.photoUrl,
    this.emailVerified = false,
    this.phoneVerified = false,
    required this.createdAt,
  });
}
