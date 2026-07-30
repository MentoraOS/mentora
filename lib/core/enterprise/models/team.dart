class Team {
  final String id;

  final String organizationId;

  final String departmentId;

  final String name;

  final String leaderId;

  final int memberCount;

  final bool active;

  const Team({
    required this.id,
    required this.organizationId,
    required this.departmentId,
    required this.name,
    required this.leaderId,
    this.memberCount = 0,
    this.active = true,
  });
}
