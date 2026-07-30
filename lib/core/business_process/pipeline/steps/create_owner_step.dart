import '../../../enterprise/engine/atlas_engine.dart';
import '../../context/enterprise_onboarding_context.dart';
import '../business_pipeline_step.dart';

class CreateOwnerStep
    extends BusinessPipelineStep<EnterpriseOnboardingContext> {
  const CreateOwnerStep();

  @override
  String get name => 'create.owner';

  @override
  Future<void> execute(EnterpriseOnboardingContext context) async {
    final userId = context.workflowContext.userId;

    if (userId == null || userId.isEmpty) {
      throw Exception('User ID is required.');
    }

    await AtlasEngine.instance.employee.join(
      employee: context.owner,
      userId: userId,
    );
  }
}
