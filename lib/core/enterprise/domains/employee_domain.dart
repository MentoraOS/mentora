import '../engine/atlas_engine.dart';
import '../models/employee.dart';

class EmployeeDomain {
  final AtlasEngine engine;

  const EmployeeDomain(this.engine);

  Future<void> invite({
    required String email,
    required String departmentId,
    required String teamId,
    required String role,
    required String userId,
  }) async {
    await engine.inviteEmployee(
      email: email,
      departmentId: departmentId,
      teamId: teamId,
      role: role,
      userId: userId,
    );
  }

  Future<void> join({
    required Employee employee,
    required String userId,
  }) async {
    await engine.employeeJoined(employee: employee, userId: userId);
  }

  Future<void> suspend({
    required Employee employee,
    required String userId,
  }) async {
    await engine.suspendEmployee(employee: employee, userId: userId);
  }

  Future<void> transfer({
    required Employee employee,
    required String newDepartmentId,
    required String newTeamId,
    required String userId,
  }) async {
    await engine.transferEmployee(
      employee: employee,
      newDepartmentId: newDepartmentId,
      newTeamId: newTeamId,
      userId: userId,
    );
  }

  Future<void> changeRole({
    required Employee employee,
    required String role,
    required String userId,
  }) async {
    await engine.changeEmployeeRole(
      employee: employee,
      newRole: role,
      userId: userId,
    );
  }

  Future<void> remove({
    required Employee employee,
    required String userId,
  }) async {
    await engine.removeEmployee(employee: employee, userId: userId);
  }
}
