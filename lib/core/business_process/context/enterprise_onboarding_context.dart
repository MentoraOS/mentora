import '../../workflow/workflow_context.dart';

import '../../enterprise/models/employee.dart';
import '../../enterprise/models/organization.dart';
import '../../enterprise/models/enterprise_workspace.dart';

import '../pipeline/business_pipeline_context.dart';

class EnterpriseOnboardingContext extends BusinessPipelineContext {
  final WorkflowContext workflowContext;

  final EnterpriseWorkspace workspace;

  final Organization organization;

  final Employee owner;

  const EnterpriseOnboardingContext({
    required this.workflowContext,
    required this.workspace,
    required this.organization,
    required this.owner,
  });
}
