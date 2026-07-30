import 'workflow_context.dart';
import 'workflow_event.dart';
import 'workflow_state.dart';

class WorkflowExecution {
  final String id;
  final String workflowName;
  final WorkflowContext context;
  final WorkflowState state;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<WorkflowEvent> events;

  const WorkflowExecution({
    required this.id,
    required this.workflowName,
    required this.context,
    required this.state,
    required this.startedAt,
    this.completedAt,
    this.events = const [],
  });

  WorkflowExecution addEvent(WorkflowEvent event) {
    return copyWith(events: [...events, event]);
  }

  WorkflowExecution copyWith({
    WorkflowState? state,
    DateTime? completedAt,
    List<WorkflowEvent>? events,
  }) {
    return WorkflowExecution(
      id: id,
      workflowName: workflowName,
      context: context,
      state: state ?? this.state,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      events: events ?? this.events,
    );
  }
}
