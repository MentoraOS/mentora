import '../engine/atlas_engine.dart';
import '../models/enterprise_project.dart';

class ProjectDomain {
  final AtlasEngine engine;

  const ProjectDomain(this.engine);

  Future<void> create({
    required EnterpriseProject project,
    required String userId,
  }) async {
    await engine.projectCreated(project: project, userId: userId);
  }

  Future<void> update({
    required EnterpriseProject project,
    required String userId,
  }) async {
    await engine.projectUpdated(project: project, userId: userId);
  }

  Future<void> archive({
    required EnterpriseProject project,
    required String userId,
  }) async {
    await engine.projectArchived(project: project, userId: userId);
  }
}
