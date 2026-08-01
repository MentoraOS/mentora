/// One recommended next step for the consultation — a PROPOSAL.
///
/// Action items bridge the consultation and its follow-through, but they
/// decide nothing and oblige no one: the expert remains the only
/// decision-maker. Each item represents exactly ONE action — never a
/// list packed into a single string. Exactly these six facts, nothing
/// else.
final class ActionItem {
  final String sessionId;
  final String actionId;
  final String title;
  final String description;
  final ActionItemPriority priority;
  final DateTime createdAt;

  factory ActionItem({
    required String sessionId,
    required String actionId,
    required String title,
    required String description,
    required ActionItemPriority priority,
    required DateTime createdAt,
  }) {
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'must not be empty');
    }
    if (description.trim().isEmpty) {
      throw ArgumentError.value(
        description,
        'description',
        'must not be empty',
      );
    }

    return ActionItem._(
      sessionId: sessionId,
      actionId: actionId,
      title: title,
      description: description,
      priority: priority,
      createdAt: createdAt,
    );
  }

  const ActionItem._({
    required this.sessionId,
    required this.actionId,
    required this.title,
    required this.description,
    required this.priority,
    required this.createdAt,
  });
}

/// The only priorities. Nothing else.
enum ActionItemPriority { low, normal, high }
