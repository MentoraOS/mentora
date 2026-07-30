import '../shared/aggregate_root.dart';
import 'settlement_domain_event.dart';
import 'settlement_id.dart';
import 'settlement_line.dart';
import 'settlement_status.dart';
import 'settlement_status_transition_policy.dart';

/// Aggregate root representing the financial settlement
/// of a completed consultation.
final class ConsultationSettlement
    extends AggregateRoot<SettlementDomainEvent> {
  ConsultationSettlement({
    required this.id,
    required List<SettlementLine> lines,
    this.status = SettlementStatus.pending,
    super.version,
  }) : _lines = List<SettlementLine>.unmodifiable(lines);

  /// Unique settlement identifier.
  final SettlementId id;

  /// Current lifecycle status.
  final SettlementStatus status;

  final List<SettlementLine> _lines;

  /// Immutable settlement lines.
  List<SettlementLine> get lines => _lines;

  /// Number of settlement lines.
  int get lineCount => _lines.length;

  /// Returns true when the settlement contains no lines.
  bool get isEmpty => _lines.isEmpty;

  /// Returns true when the settlement contains at least one line.
  bool get isNotEmpty => _lines.isNotEmpty;

  /// Returns true when the settlement completed successfully.
  bool get isCompleted => status.isSuccessful;

  /// Returns true while financial processing may continue.
  bool get isActive => status.isActive;

  /// Returns true when processing is currently running.
  bool get isProcessing => status.isProcessing;

  /// Returns true when processing failed.
  bool get isFailed => status.isFailed;

  /// Returns true when the settlement was cancelled.
  bool get isCancelled => status.isCancelled;

  /// Returns true when the settlement was refunded.
  bool get isRefunded => status.isRefunded;

  /// Starts financial processing.
  ConsultationSettlement markProcessing({DateTime? occurredAt}) {
    return transitionTo(SettlementStatus.processing, occurredAt: occurredAt);
  }

  /// Completes financial processing successfully.
  ConsultationSettlement markCompleted({DateTime? occurredAt}) {
    return transitionTo(SettlementStatus.completed, occurredAt: occurredAt);
  }

  /// Marks financial processing as failed.
  ConsultationSettlement markFailed({
    required String reason,
    DateTime? occurredAt,
  }) {
    return transitionTo(
      SettlementStatus.failed,
      occurredAt: occurredAt,
      failureReason: reason,
    );
  }

  /// Cancels the settlement before completion.
  ConsultationSettlement markCancelled({DateTime? occurredAt}) {
    return transitionTo(SettlementStatus.cancelled, occurredAt: occurredAt);
  }

  /// Refunds a previously completed settlement.
  ConsultationSettlement markRefunded({DateTime? occurredAt}) {
    return transitionTo(SettlementStatus.refunded, occurredAt: occurredAt);
  }

  /// Performs a validated settlement lifecycle transition.
  ///
  /// A new aggregate instance is returned. When the status changes,
  /// the corresponding domain event is recorded and the aggregate
  /// version is incremented by AggregateRoot.
  ConsultationSettlement transitionTo(
    SettlementStatus nextStatus, {
    DateTime? occurredAt,
    String? failureReason,
  }) {
    SettlementStatusTransitionPolicy.ensureCanTransition(
      from: status,
      to: nextStatus,
    );

    if (nextStatus == status) {
      return this;
    }

    final transitioned = ConsultationSettlement(
      id: id,
      lines: _lines,
      status: nextStatus,
      version: version,
    );

    transitioned.recordDomainEvent(
      settlementEventForTransition(
        settlementId: id,
        targetStatus: nextStatus,
        occurredAt: (occurredAt ?? DateTime.now()).toUtc(),
        failureReason: failureReason,
      ),
    );

    return transitioned;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ConsultationSettlement &&
            other.id == id &&
            other.status == status &&
            other.version == version &&
            _listEquals(other._lines, _lines);
  }

  @override
  int get hashCode => Object.hash(id, status, version, Object.hashAll(_lines));

  @override
  String toString() {
    return 'ConsultationSettlement('
        'id: $id, '
        'status: $status, '
        'lines: ${_lines.length}, '
        'version: $version'
        ')';
  }

  static bool _listEquals(List<SettlementLine> a, List<SettlementLine> b) {
    if (identical(a, b)) {
      return true;
    }

    if (a.length != b.length) {
      return false;
    }

    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) {
        return false;
      }
    }

    return true;
  }
}
