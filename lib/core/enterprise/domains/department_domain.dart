import '../engine/atlas_engine.dart';
import '../models/department.dart';

class DepartmentDomain {
  final AtlasEngine engine;

  const DepartmentDomain(this.engine);

  Future<void> create({
    required Department department,
    required String userId,
  }) async {
    await engine.createDepartment(department: department, userId: userId);
  }

  Future<void> update({
    required Department department,
    required String userId,
  }) async {
    await engine.updateDepartment(department: department, userId: userId);
  }

  Future<void> archive({
    required Department department,
    required String userId,
  }) async {
    await engine.archiveDepartment(department: department, userId: userId);
  }
}
