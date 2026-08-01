import '../consultation_memory/consultation_memory.dart';
import 'assistant_suggestion.dart';

/// Consultation copilot boundary.
///
/// The provider receives ONLY the consultation memory — never any other
/// business module — and produces a LIVING flux of contextual
/// suggestions. It decides nothing, acts on nothing and persists
/// nothing. The implementation routes through the AI gateway; engines
/// are added by registering another gateway adapter and nothing in the
/// business layers changes. Future copilot capabilities (reminders,
/// question recommendations, contextual alerts, uncovered points,
/// resources, interim syntheses, report preparation, multilingual
/// assistance) are new prompt variants behind this same contract.
abstract interface class AssistantProvider {
  /// Attaches the copilot to one session over the memory's recorded
  /// facts and starts the living suggestion flux.
  Future<AssistantStream> start({
    required String sessionId,
    required ConsultationMemory memory,
  });
}

/// One session's continuous suggestion flux.
abstract interface class AssistantStream {
  AssistantStatus get status;

  /// The live suggestions. Errors surface ON this stream — fail closed,
  /// never silently swallowed.
  Stream<AssistantSuggestion> get suggestions;

  /// Asks the copilot to look again at the (re-read) memory; new
  /// suggestions join the same flux.
  Future<void> refresh(ConsultationMemory memory);

  /// Detaches the copilot and seals the flux.
  Future<AssistantResult> stop();
}

/// The lifecycle of one living copilot flux. Nothing else.
enum AssistantStatus { assisting, stopped, failed }

/// The sealed outcome of one copilot session.
final class AssistantResult {
  final String sessionId;
  final AssistantStatus status;

  const AssistantResult({required this.sessionId, required this.status});
}

sealed class AssistantFailure implements Exception {
  const AssistantFailure();
}

final class AssistantUnauthenticatedFailure extends AssistantFailure {
  const AssistantUnauthenticatedFailure();
}

/// One live copilot at a time, ever.
final class AssistantAlreadyActiveFailure extends AssistantFailure {
  const AssistantAlreadyActiveFailure();
}

/// No reservation with this identity involves this user.
final class AssistantNotFoundFailure extends AssistantFailure {
  const AssistantNotFoundFailure();
}

final class AssistantUnavailableFailure extends AssistantFailure {
  const AssistantUnavailableFailure({required this.cause});

  final Object cause;
}
