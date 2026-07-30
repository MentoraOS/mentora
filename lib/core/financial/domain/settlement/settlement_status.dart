enum SettlementStatus {
  /// Settlement has been created but processing
  /// has not started yet.
  pending,

  /// Financial processing is currently running.
  processing,

  /// Settlement has been completed successfully.
  completed,

  /// Settlement processing failed.
  failed,

  /// Settlement was cancelled before completion.
  cancelled,

  /// Settlement was completed but later refunded.
  refunded;

  /// Returns true when the settlement has reached
  /// a terminal state.
  bool get isFinal =>
      this == completed ||
      this == failed ||
      this == cancelled ||
      this == refunded;

  /// Returns true when processing may continue.
  bool get isActive => this == pending || this == processing;

  /// Returns true when the settlement succeeded.
  bool get isSuccessful => this == completed;

  /// Returns true when the settlement failed.
  bool get isFailed => this == failed;

  /// Returns true when the settlement has been cancelled.
  bool get isCancelled => this == cancelled;

  /// Returns true when the settlement has been refunded.
  bool get isRefunded => this == refunded;

  /// Returns true when the settlement is currently
  /// being processed.
  bool get isProcessing => this == processing;

  /// Returns true when the settlement is waiting
  /// to begin processing.
  bool get isPending => this == pending;
}
