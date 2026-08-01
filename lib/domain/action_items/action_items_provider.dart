import '../consultation_memory/consultation_memory.dart';
import 'action_item.dart';

/// Action recommendation boundary.
///
/// The provider receives ONLY the consultation memory — never any other
/// business module — and produces a LIVING flux of individual action
/// proposals. No automation, no workflow, no notification, no decision:
/// the expert alone decides what happens next. The implementation routes
/// through the AI gateway; engines are added by registering another
/// gateway adapter and nothing in the business layers changes. Future
/// capabilities (expert validation, edition, rejection, task
/// conversion, calendar sync, reminders, CRM, tracking, dashboards)
/// build ON TOP of these proposals, behind their own contracts.
abstract interface class ActionItemsProvider {
  /// Attaches to one session over the memory's recorded facts and starts
  /// the living proposal flux.
  Future<ActionItemsStream> start({
    required String sessionId,
    required ConsultationMemory memory,
  });
}

/// One session's continuous proposal flux.
abstract interface class ActionItemsStream {
  ActionItemsStatus get status;

  /// The live proposals, one action each. Errors surface ON this stream
  /// — fail closed, never silently swallowed.
  Stream<ActionItem> get items;

  /// Asks for proposals again over the (re-read) memory; new items join
  /// the same flux.
  Future<void> refresh(ConsultationMemory memory);

  /// Detaches and seals the flux.
  Future<ActionItemsResult> stop();
}

/// The lifecycle of one living proposal flux. Nothing else.
enum ActionItemsStatus { proposing, stopped, failed }

/// The sealed outcome of one proposal session.
final class ActionItemsResult {
  final String sessionId;
  final ActionItemsStatus status;

  const ActionItemsResult({required this.sessionId, required this.status});
}

sealed class ActionItemsFailure implements Exception {
  const ActionItemsFailure();
}

final class ActionItemsUnauthenticatedFailure extends ActionItemsFailure {
  const ActionItemsUnauthenticatedFailure();
}

/// One live proposal flux at a time, ever.
final class ActionItemsAlreadyActiveFailure extends ActionItemsFailure {
  const ActionItemsAlreadyActiveFailure();
}

/// No reservation with this identity involves this user.
final class ActionItemsNotFoundFailure extends ActionItemsFailure {
  const ActionItemsNotFoundFailure();
}

final class ActionItemsUnavailableFailure extends ActionItemsFailure {
  const ActionItemsUnavailableFailure({required this.cause});

  final Object cause;
}
