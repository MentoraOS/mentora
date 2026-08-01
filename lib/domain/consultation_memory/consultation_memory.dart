/// The single memory of one consultation.
///
/// One reservation owns EXACTLY one memory, identified by the booking id
/// itself (memoryId == bookingId). It records durable BUSINESS FACTS and
/// nothing else — never the output of any AI engine — so Mentora can swap
/// engines forever without migrating a single byte of memory. Every
/// future intelligence capability (summaries, translation, assistance,
/// semantic search, recommendations, analytics) READS this memory through
/// its own port; none of that exists today.
final class ConsultationMemory {
  /// Also the memory identity: memoryId == bookingId.
  final String bookingId;

  /// The recorded facts, oldest first.
  final List<MemoryEntry> entries;

  final DateTime? createdAt;

  ConsultationMemory({
    required this.bookingId,
    required List<MemoryEntry> entries,
    required this.createdAt,
  }) : entries = List.unmodifiable(entries);
}

/// The only kinds of fact the memory may hold. No other type exists.
enum MemoryEntryType {
  chatMessage,
  consultationBrief,
  privateNote,
  sharedDocument,
  consultationStarted,
  consultationCompleted,
  bookingConfirmed,
  bookingRescheduled,
  bookingCancelled,
  reviewCreated,
}

/// One recorded business fact.
final class MemoryEntry {
  final String id;
  final String bookingId;
  final MemoryEntryType type;

  /// Server-side instant; null only during server-timestamp latency.
  final DateTime? createdAt;

  /// Opaque fact payload (raw business values keyed by name). It can
  /// carry a message, a document reference, a note, a brief, metadata or
  /// event details — nothing in Mentora parses or interprets it.
  final Map<String, Object?> payload;

  factory MemoryEntry({
    required String id,
    required String bookingId,
    required MemoryEntryType type,
    required DateTime? createdAt,
    Map<String, Object?> payload = const {},
  }) {
    if (bookingId.trim().isEmpty) {
      throw ArgumentError.value(bookingId, 'bookingId', 'must not be empty');
    }

    return MemoryEntry._(
      id: id,
      bookingId: bookingId,
      type: type,
      createdAt: createdAt,
      payload: Map.unmodifiable(payload),
    );
  }

  const MemoryEntry._({
    required this.id,
    required this.bookingId,
    required this.type,
    required this.createdAt,
    required this.payload,
  });
}

sealed class MemoryFailure implements Exception {
  const MemoryFailure();
}

final class MemoryUnauthenticatedFailure extends MemoryFailure {
  const MemoryUnauthenticatedFailure();
}

/// No reservation with this identity involves this user.
final class MemoryNotFoundFailure extends MemoryFailure {
  const MemoryNotFoundFailure();
}

final class MemoryUnavailableFailure extends MemoryFailure {
  const MemoryUnavailableFailure({required this.cause});

  final Object cause;
}
