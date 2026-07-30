import '../models/enterprise_membership.dart';

class EnterpriseMembershipRepository {
  EnterpriseMembershipRepository._();

  static const List<EnterpriseMembership> memberships = [
    EnterpriseMembership(
      id: 'membership_finance_member',
      userId: 'current_user',
      employeeId: 'emp_010',
      organizationId: 'mentora_demo',
      workspaceId: 'abc_mali',
      departmentId: 'finance',
      teamId: 'finance_accounting',
      managerId: 'emp_001',
      role: 'finance_member',
      permissions: ['learning.view', 'sessions.join'],
    ),
  ];

  static EnterpriseMembership? findByUserAndWorkspace({
    required String userId,
    required String workspaceId,
  }) {
    try {
      return memberships.firstWhere(
        (membership) =>
            membership.userId == userId &&
            membership.workspaceId == workspaceId &&
            membership.active,
      );
    } catch (_) {
      return null;
    }
  }
}
