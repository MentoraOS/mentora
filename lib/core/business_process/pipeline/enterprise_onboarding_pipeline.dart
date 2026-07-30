import '../context/enterprise_onboarding_context.dart';

import 'business_pipeline.dart';

import 'steps/create_workspace_step.dart';
import 'steps/create_organization_step.dart';
import 'steps/create_owner_step.dart';

class EnterpriseOnboardingPipeline
    extends BusinessPipeline<EnterpriseOnboardingContext> {
  EnterpriseOnboardingPipeline()
    : super(
        name: 'enterprise.onboarding',
        steps: const [
          CreateWorkspaceStep(),
          CreateOrganizationStep(),
          CreateOwnerStep(),
        ],
      );
}
