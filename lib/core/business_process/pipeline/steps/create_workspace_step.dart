import '../../../enterprise/engine/atlas_engine.dart';

import '../business_pipeline_step.dart';

import '../../context/enterprise_onboarding_context.dart';

class CreateWorkspaceStep
    extends BusinessPipelineStep<EnterpriseOnboardingContext> {
  const CreateWorkspaceStep();

  @override
  String get name => 'create.workspace';

  @override
  Future<void> execute(EnterpriseOnboardingContext context) async {
    final userId = context.workflowContext.userId;

    if (userId == null || userId.isEmpty) {
      throw Exception('User ID is required.');
    }

    await AtlasEngine.instance.workspace.create(
      workspace: context.workspace,
      userId: userId,
    );
  }
}
