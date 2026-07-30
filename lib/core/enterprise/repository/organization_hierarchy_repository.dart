import '../models/organization_hierarchy.dart';

class OrganizationHierarchyRepository {
  OrganizationHierarchyRepository._();

  static const List<OrganizationHierarchy> hierarchies = [
    OrganizationHierarchy(
      organizationId: 'mentora_demo',
      managerByEmployeeId: {
        'emp_001': '',
        'emp_010': 'emp_001',
        'emp_011': 'emp_001',
        'emp_020': 'emp_003',
      },
    ),
  ];

  static OrganizationHierarchy? findByOrganization(String organizationId) {
    try {
      return hierarchies.firstWhere(
        (hierarchy) => hierarchy.organizationId == organizationId,
      );
    } catch (_) {
      return null;
    }
  }
}
