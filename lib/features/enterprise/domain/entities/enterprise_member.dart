class EnterpriseMember {
  final String id;
  final String workspaceId;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String department;
  final bool active;

  const EnterpriseMember({
    required this.id,
    required this.workspaceId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.department,
    required this.active,
  });

  String get fullName => '$firstName $lastName';
}
