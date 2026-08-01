sealed class ConversationFailure implements Exception {
  const ConversationFailure();
}

final class ConversationUnauthenticatedFailure extends ConversationFailure {
  const ConversationUnauthenticatedFailure();
}

/// No reservation with this identity involves this user.
final class ConversationNotFoundFailure extends ConversationFailure {
  const ConversationNotFoundFailure();
}

/// Only confirmed, paid or completed reservations converse.
final class ConversationInvalidStateFailure extends ConversationFailure {
  const ConversationInvalidStateFailure({required this.currentStatus});

  final String currentStatus;
}

/// Text messages must carry text.
final class ConversationEmptyMessageFailure extends ConversationFailure {
  const ConversationEmptyMessageFailure();
}

final class ConversationRepositoryFailure extends ConversationFailure {
  const ConversationRepositoryFailure({required this.cause});

  final Object cause;
}
