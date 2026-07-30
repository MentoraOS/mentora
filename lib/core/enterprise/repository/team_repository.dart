import '../models/team.dart';

class TeamRepository {
  TeamRepository._();

  static const List<Team> teams = [
    Team(
      id: 'finance_accounting',
      organizationId: 'mentora_demo',
      departmentId: 'finance',
      name: 'Comptabilité',
      leaderId: 'emp_010',
      memberCount: 8,
    ),

    Team(
      id: 'finance_audit',
      organizationId: 'mentora_demo',
      departmentId: 'finance',
      name: 'Audit',
      leaderId: 'emp_011',
      memberCount: 6,
    ),

    Team(
      id: 'it_mobile',
      organizationId: 'mentora_demo',
      departmentId: 'it',
      name: 'Mobile',
      leaderId: 'emp_020',
      memberCount: 12,
    ),
  ];

  static List<Team> byDepartment(String departmentId) {
    return teams.where((team) => team.departmentId == departmentId).toList();
  }
}
