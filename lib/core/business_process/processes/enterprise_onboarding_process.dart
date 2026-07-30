import '../business_process.dart';
import '../business_process_result.dart';
import '../context/enterprise_onboarding_context.dart';
import '../../enterprise/models/organization.dart';
import '../../enterprise/models/employee.dart';
import '../../enterprise/models/enterprise_workspace.dart';
import '../../workflow/workflow_context.dart';
import '../pipeline/enterprise_onboarding_pipeline.dart';

class EnterpriseOnboardingProcess
    extends BusinessProcess<BusinessProcessResult<void>> {
  final Organization organization;
  final EnterpriseWorkspace workspace;
  final Employee owner;
  final WorkflowContext context;

  const EnterpriseOnboardingProcess({
    required this.organization,
    required this.workspace,
    required this.owner,
    required this.context,
  });

  @override
  String get name => 'enterprise.onboarding';

  @override
  Future<BusinessProcessResult<void>> run() async {
    final pipeline = EnterpriseOnboardingPipeline();

    final pipelineContext = EnterpriseOnboardingContext(
      workflowContext: context,
      workspace: workspace,
      organization: organization,
      owner: owner,
    );

    await pipeline.run(pipelineContext);

    return const BusinessProcessResult.success(
      message: 'Enterprise created successfully',
    );
  }
}
