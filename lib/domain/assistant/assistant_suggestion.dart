/// One contextual suggestion from the consultation copilot.
///
/// The assistant NEVER replaces the expert, never interrupts the
/// consultation, never speaks to the client and never acts on its own:
/// it only proposes. Exactly these six facts, nothing else.
final class AssistantSuggestion {
  final String sessionId;
  final String suggestionId;
  final String title;
  final String content;
  final AssistantPriority priority;
  final DateTime createdAt;

  factory AssistantSuggestion({
    required String sessionId,
    required String suggestionId,
    required String title,
    required String content,
    required AssistantPriority priority,
    required DateTime createdAt,
  }) {
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'must not be empty');
    }
    if (content.trim().isEmpty) {
      throw ArgumentError.value(content, 'content', 'must not be empty');
    }

    return AssistantSuggestion._(
      sessionId: sessionId,
      suggestionId: suggestionId,
      title: title,
      content: content,
      priority: priority,
      createdAt: createdAt,
    );
  }

  const AssistantSuggestion._({
    required this.sessionId,
    required this.suggestionId,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
  });
}

/// The only priorities. Nothing else.
enum AssistantPriority { low, normal, high }
