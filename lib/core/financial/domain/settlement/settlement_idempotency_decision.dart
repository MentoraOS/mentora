/// Decision returned after checking an existing settlement.
///
/// The pipeline uses this decision to determine whether
/// it should continue, retry, resume or stop.
enum SettlementIdempotencyDecision {
  /// No previous settlement exists.
  continueProcessing,

  /// Resume an unfinished settlement.
  resume,

  /// Retry a failed settlement.
  retry,

  /// Settlement already completed.
  alreadyCompleted,

  /// Settlement cannot continue anymore.
  reject,
}
