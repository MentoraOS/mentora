import 'workflow_state.dart';

class WorkflowResult<T> {
  final WorkflowState state;

  final T? data;

  final String? message;

  const WorkflowResult._({required this.state, this.data, this.message});

  bool get isSuccess => state == WorkflowState.completed;

  bool get isFailure => state == WorkflowState.failed;

  bool get isCancelled => state == WorkflowState.cancelled;

  factory WorkflowResult.success({T? data, String? message}) {
    return WorkflowResult._(
      state: WorkflowState.completed,
      data: data,
      message: message,
    );
  }

  factory WorkflowResult.failure({String? message}) {
    return WorkflowResult._(state: WorkflowState.failed, message: message);
  }

  factory WorkflowResult.cancelled({String? message}) {
    return WorkflowResult._(state: WorkflowState.cancelled, message: message);
  }
}
