import '../models/department.dart';

class DepartmentRepository {
  DepartmentRepository._();

  static final List<Department> departments = [
    Department(
      id: 'finance',
      organizationId: 'mentora_demo',
      name: 'Finance',
      code: 'FIN',
      description: 'Département Finance',
      managerId: 'emp_fin_manager',
      employeeCount: 18,
    ),

    Department(
      id: 'hr',
      organizationId: 'mentora_demo',
      name: 'Ressources Humaines',
      code: 'HR',
      description: 'Département RH',
      managerId: 'emp_hr_manager',
      employeeCount: 10,
    ),

    Department(
      id: 'it',
      organizationId: 'mentora_demo',
      name: 'Technologie',
      code: 'IT',
      description: 'Département Technique',
      managerId: 'emp_cto',
      employeeCount: 35,
    ),
  ];

  static List<Department> byOrganization(String organizationId) {
    return departments
        .where((department) => department.organizationId == organizationId)
        .toList();
  }
}
