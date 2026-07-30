import '../workflow_context.dart';
import '../workflow_engine.dart';

import '../../enterprise/models/employee.dart';
import '../../workflow/employee_onboarding_workflow.dart';

class WorkflowRegistry {
  WorkflowRegistry._();

  static Future<void> employeeOnboarding({
    required Employee employee,
    required WorkflowContext context,
  }) async {
    await WorkflowEngine.execute<Employee>(
      workflow: EmployeeOnboardingWorkflow(employee: employee),
      context: context,
    );
  }
}
