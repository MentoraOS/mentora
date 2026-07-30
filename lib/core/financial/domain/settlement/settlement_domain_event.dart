import 'settlement_id.dart';
import 'settlement_status.dart';

/// Base contract for every domain event emitted by a settlement.
sealed class SettlementDomainEvent {
  const SettlementDomainEvent({
    required this.settlementId,
    required this.occurredAt,
  });

  final SettlementId settlementId;
  final DateTime occurredAt;
}

/// Emitted when settlement financial processing starts.
final class SettlementProcessingStarted extends SettlementDomainEvent {
  const SettlementProcessingStarted({
    required super.settlementId,
    required super.occurredAt,
  });
}

/// Emitted when settlement processing completes successfully.
final class SettlementCompleted extends SettlementDomainEvent {
  const SettlementCompleted({
    required super.settlementId,
    required super.occurredAt,
  });
}

/// Emitted when settlement processing fails.
final class SettlementFailed extends SettlementDomainEvent {
  const SettlementFailed({
    required super.settlementId,
    required super.occurredAt,
    required this.reason,
  });

  final String reason;
}

/// Emitted when a settlement is cancelled.
final class SettlementCancelled extends SettlementDomainEvent {
  const SettlementCancelled({
    required super.settlementId,
    required super.occurredAt,
  });
}

/// Emitted when a completed settlement is refunded.
final class SettlementRefunded extends SettlementDomainEvent {
  const SettlementRefunded({
    required super.settlementId,
    required super.occurredAt,
  });
}

/// Maps a target settlement status to its domain event.
SettlementDomainEvent settlementEventForTransition({
  required SettlementId settlementId,
  required SettlementStatus targetStatus,
  required DateTime occurredAt,
  String? failureReason,
}) {
  return switch (targetStatus) {
    SettlementStatus.processing => SettlementProcessingStarted(
      settlementId: settlementId,
      occurredAt: occurredAt,
    ),
    SettlementStatus.completed => SettlementCompleted(
      settlementId: settlementId,
      occurredAt: occurredAt,
    ),
    SettlementStatus.failed => SettlementFailed(
      settlementId: settlementId,
      occurredAt: occurredAt,
      reason: _requireFailureReason(failureReason),
    ),
    SettlementStatus.cancelled => SettlementCancelled(
      settlementId: settlementId,
      occurredAt: occurredAt,
    ),
    SettlementStatus.refunded => SettlementRefunded(
      settlementId: settlementId,
      occurredAt: occurredAt,
    ),
    SettlementStatus.pending => throw StateError(
      'No settlement domain event exists for transition to pending.',
    ),
  };
}

String _requireFailureReason(String? reason) {
  final normalized = reason?.trim() ?? '';

  if (normalized.isEmpty) {
    throw ArgumentError.value(
      reason,
      'failureReason',
      'A failure reason is required for a failed settlement.',
    );
  }

  return normalized;
}
