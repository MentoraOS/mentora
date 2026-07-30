enum PermissionScope {
  global,
  workspace,
  organization,
  department,
  team,
  personal,
}

class Permission {
  final String id;
  final String key;
  final String name;
  final String description;
  final String category;
  final PermissionScope scope;
  final bool enabled;

  const Permission({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.category,
    required this.scope,
    this.enabled = true,
  });
}
