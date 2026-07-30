import '../models/employee.dart';

class EmployeeRepository {
  EmployeeRepository._();

  static final List<Employee> employees = [
    Employee(
      id: 'emp_001',
      organizationId: 'mentora_demo',
      departmentId: 'finance',
      teamId: 'finance_accounting',
      managerId: '',
      firstName: 'Aminata',
      lastName: 'Diallo',
      email: 'aminata@mentora.io',
      phone: '+22370000000',
      position: 'Finance Director',
      photoUrl: '',
      hireDate: DateTime(2024, 1, 10),
    ),
  ];

  static Employee? findById(String id) {
    try {
      return employees.firstWhere((employee) => employee.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Employee> byDepartment(String departmentId) {
    return employees
        .where((employee) => employee.departmentId == departmentId)
        .toList();
  }

  static List<Employee> byTeam(String teamId) {
    return employees.where((employee) => employee.teamId == teamId).toList();
  }
}
