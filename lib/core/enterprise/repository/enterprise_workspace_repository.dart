import '../models/enterprise_workspace.dart';

class EnterpriseWorkspaceRepository {
  EnterpriseWorkspaceRepository._();

  static final List<EnterpriseWorkspace> workspaces = [
    EnterpriseWorkspace(
      id: 'abc_mali',
      name: 'ABC Mali',
      ownerId: 'current_user',
      country: 'Mali',
      currency: 'XOF',
      timezone: 'Africa/Bamako',
      plan: 'enterprise',
      maxOrganizations: 5,
      maxEmployees: 500,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  static EnterpriseWorkspace? findById(String id) {
    try {
      return workspaces.firstWhere((workspace) => workspace.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<EnterpriseWorkspace> findAll() {
    return workspaces;
  }
}
