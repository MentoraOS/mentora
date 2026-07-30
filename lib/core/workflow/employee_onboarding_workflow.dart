import '../../core/workflow/workflow.dart';
import '../../core/workflow/workflow_context.dart';
import '../../core/workflow/workflow_result.dart';
import '../../core/enterprise/engine/atlas_engine.dart';
import '../../core/enterprise/models/employee.dart';

class EmployeeOnboardingWorkflow extends Workflow<Employee> {
  final Employee employee;

  const EmployeeOnboardingWorkflow({required this.employee});

  @override
  String get name => 'employee.onboarding';

  @override
  Future<WorkflowResult<Employee>> execute(WorkflowContext context) async {
    await AtlasEngine.instance.employee.join(
      employee: employee,
      userId: context.userId ?? '',
    );

    return WorkflowResult.success(
      data: employee,
      message: 'Employee onboarding completed',
    );
  }
}
