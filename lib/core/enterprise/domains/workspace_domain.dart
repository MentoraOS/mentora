import '../engine/atlas_engine.dart';
import '../models/enterprise_workspace.dart';

class WorkspaceDomain {
  final AtlasEngine engine;

  const WorkspaceDomain(this.engine);

  Future<void> create({
    required EnterpriseWorkspace workspace,
    required String userId,
  }) async {
    await engine.workspaceCreated(workspace: workspace, userId: userId);
  }

  Future<void> update({
    required EnterpriseWorkspace workspace,
    required String userId,
  }) async {
    await engine.workspaceUpdated(workspace: workspace, userId: userId);
  }

  Future<void> suspend({
    required EnterpriseWorkspace workspace,
    required String userId,
  }) async {
    await engine.workspaceSuspended(workspace: workspace, userId: userId);
  }

  Future<void> archive({
    required EnterpriseWorkspace workspace,
    required String userId,
  }) async {
    await engine.workspaceArchived(workspace: workspace, userId: userId);
  }
}
