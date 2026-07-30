class EnterpriseRole {
  final String id;
  final String name;
  final String description;
  final int level;
  final bool systemRole;

  const EnterpriseRole({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    this.systemRole = false,
  });
}
