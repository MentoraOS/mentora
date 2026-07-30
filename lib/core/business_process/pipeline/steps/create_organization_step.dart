import '../../../enterprise/engine/atlas_engine.dart';
import '../../context/enterprise_onboarding_context.dart';
import '../business_pipeline_step.dart';

class CreateOrganizationStep
    extends BusinessPipelineStep<EnterpriseOnboardingContext> {
  const CreateOrganizationStep();

  @override
  String get name => 'create.organization';

  @override
  Future<void> execute(EnterpriseOnboardingContext context) async {
    final userId = context.workflowContext.userId;

    if (userId == null || userId.isEmpty) {
      throw Exception('User ID is required.');
    }

    await AtlasEngine.instance.organization.create(
      organization: context.organization,
      userId: userId,
    );
  }
}
