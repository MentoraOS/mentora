class Role {
  final String id;
  final String key;
  final String name;
  final String description;
  final List<String> permissions;
  final bool systemRole;

  const Role({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.permissions,
    this.systemRole = false,
  });
}
