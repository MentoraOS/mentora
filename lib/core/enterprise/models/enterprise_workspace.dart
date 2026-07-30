enum EnterpriseWorkspaceStatus { active, suspended, archived }

class EnterpriseWorkspace {
  final String id;
  final String name;
  final String ownerId;

  final String country;
  final String currency;
  final String timezone;

  final String plan;
  final int maxOrganizations;
  final int maxEmployees;

  final EnterpriseWorkspaceStatus status;

  final DateTime createdAt;

  const EnterpriseWorkspace({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.country,
    required this.currency,
    required this.timezone,
    required this.plan,
    required this.maxOrganizations,
    required this.maxEmployees,
    this.status = EnterpriseWorkspaceStatus.active,
    required this.createdAt,
  });
}
