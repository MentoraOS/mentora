import '../models/enterprise_permission.dart';

class EnterprisePermissionRepository {
  EnterprisePermissionRepository._();

  static const List<EnterprisePermission> permissions = [
    EnterprisePermission(
      id: 'learning.view',
      name: 'Voir formations',
      description: 'Permet de consulter les formations.',
      domain: 'learning',
    ),
    EnterprisePermission(
      id: 'sessions.join',
      name: 'Rejoindre sessions',
      description: 'Permet de rejoindre les sessions.',
      domain: 'sessions',
    ),
    EnterprisePermission(
      id: 'employees.manage',
      name: 'Gérer employés',
      description: 'Permet de gérer les collaborateurs.',
      domain: 'enterprise',
    ),
    EnterprisePermission(
      id: 'finance.manage',
      name: 'Gérer finance',
      description: 'Permet de gérer les opérations financières.',
      domain: 'finance',
    ),
  ];

  static EnterprisePermission? findById(String id) {
    try {
      return permissions.firstWhere((permission) => permission.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<EnterprisePermission> findAll() {
    return permissions;
  }

  static List<EnterprisePermission> byDomain(String domain) {
    return permissions
        .where((permission) => permission.domain == domain)
        .toList();
  }
}
