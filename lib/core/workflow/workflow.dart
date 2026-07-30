import 'workflow_context.dart';
import 'workflow_result.dart';

abstract class Workflow<T> {
  const Workflow();

  /// Nom du workflow (utile pour les logs, audit et analytics)
  String get name;

  /// Point d'entrée principal
  Future<WorkflowResult<T>> execute(WorkflowContext context);
}
