class Department {
  final String id;

  final String organizationId;

  final String name;

  final String code;

  final String description;

  final String managerId;

  final int employeeCount;

  final bool active;

  const Department({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.code,
    required this.description,
    required this.managerId,
    this.employeeCount = 0,
    this.active = true,
  });
}
