class IdentityPermission {
  final String id;
  final String name;
  final String label;
  final String description;

  const IdentityPermission({
    required this.id,
    required this.name,
    required this.label,
    this.description = '',
  });
}
