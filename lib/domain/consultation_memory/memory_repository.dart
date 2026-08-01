import 'consultation_memory.dart';

/// Port for the consultation memory: record one business fact, read the
/// memory back — nothing else.
///
/// GOVERNANCE (ARC-MEM01): no AI engine may ever write here directly.
/// Every write passes through ConsultationMemoryApplicationService and
/// this port; the AI gateway has no dependency on the memory, in either
/// direction.
abstract interface class MemoryRepository {
  /// Appends one fact to the reservation's single memory.
  ///
  /// The reservation must exist and [userId] must be its client or expert
  /// — anything else throws [MemoryEntryNotFoundException].
  Future<void> record({
    required String bookingId,
    required String userId,
    required MemoryEntryType type,
    required Map<String, Object?> payload,
  });

  /// The reservation's memory, entries oldest first. Same guards as
  /// [record]; a reservation without recorded facts reads as an empty
  /// memory, never as an error.
  Future<ConsultationMemory> read({
    required String bookingId,
    required String userId,
  });
}

final class MemoryEntryNotFoundException implements Exception {
  const MemoryEntryNotFoundException();
}

final class MemoryEntryRepositoryException implements Exception {
  const MemoryEntryRepositoryException({required this.cause});

  final Object cause;
}
