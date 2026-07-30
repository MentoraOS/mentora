class Employee {
  final String id;

  final String organizationId;

  final String departmentId;

  final String teamId;

  final String managerId;

  final String firstName;

  final String lastName;

  final String email;

  final String phone;

  final String position;

  final String photoUrl;

  final DateTime hireDate;

  final bool active;

  const Employee({
    required this.id,
    required this.organizationId,
    required this.departmentId,
    required this.teamId,
    required this.managerId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.position,
    required this.photoUrl,
    required this.hireDate,
    this.active = true,
  });

  String get fullName => '$firstName $lastName';
}
