import '../models/enterprise_role.dart';

class EnterpriseRoleRepository {
  EnterpriseRoleRepository._();

  static const List<EnterpriseRole> roles = [
    EnterpriseRole(
      id: 'director',
      name: 'Directeur',
      description: 'Pilote la vision globale de l’entreprise.',
      level: 100,
      systemRole: true,
    ),
    EnterpriseRole(
      id: 'hr_admin',
      name: 'RH Admin',
      description: 'Gère les employés, invitations et parcours RH.',
      level: 80,
      systemRole: true,
    ),
    EnterpriseRole(
      id: 'finance_manager',
      name: 'Finance Manager',
      description: 'Gère les finances, budgets et validations financières.',
      level: 70,
      systemRole: true,
    ),
    EnterpriseRole(
      id: 'finance_member',
      name: 'Finance Member',
      description: 'Membre du département Finance.',
      level: 40,
      systemRole: true,
    ),
    EnterpriseRole(
      id: 'employee',
      name: 'Employé',
      description: 'Collaborateur standard de l’entreprise.',
      level: 10,
      systemRole: true,
    ),
  ];

  static EnterpriseRole? findById(String id) {
    try {
      return roles.firstWhere((role) => role.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<EnterpriseRole> findAll() {
    return roles;
  }
}
