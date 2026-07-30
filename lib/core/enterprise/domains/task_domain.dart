import '../engine/atlas_engine.dart';
import '../models/enterprise_task.dart';

class TaskDomain {
  final AtlasEngine engine;

  const TaskDomain(this.engine);

  Future<void> create({
    required EnterpriseTask task,
    required String userId,
  }) async {
    await engine.taskCreated(task: task, userId: userId);
  }

  Future<void> update({
    required EnterpriseTask task,
    required String userId,
  }) async {
    await engine.taskUpdated(task: task, userId: userId);
  }

  Future<void> complete({
    required EnterpriseTask task,
    required String userId,
  }) async {
    await engine.taskCompleted(task: task, userId: userId);
  }
}
