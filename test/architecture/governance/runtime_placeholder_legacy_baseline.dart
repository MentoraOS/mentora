/// Runtime placeholder legacy baseline.
///
/// Sprint -1.2 / Lot E.4.
///
/// Existing entries describe historical runtime debt.
/// They are not approved patterns for new code.
abstract final class RuntimePlaceholderLegacyBaseline {
  static const bool initialized = true;

  static const Set<String> violations = {
    'demoRuntime|core/enterprise/repository/department_repository.dart',
    'demoRuntime|core/enterprise/repository/employee_repository.dart',
    'demoRuntime|core/enterprise/repository/enterprise_membership_repository.dart',
    'demoRuntime|core/enterprise/repository/organization_hierarchy_repository.dart',
    'demoRuntime|core/enterprise/repository/organization_repository.dart',
    'demoRuntime|core/enterprise/repository/team_repository.dart',
    'mockRuntime|core/engines/payment/providers/mock_payment_provider.dart',
    'todo|screens/enterprise/employee/widgets/learning_session/lesson_resources.dart',
    'todo|screens/enterprise/employee/widgets/quick_actions_card.dart',
  };
}
