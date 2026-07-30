// Decision produced by a financial recovery strategy.
//
// The decision describes what the recovery infrastructure should do
// after inspecting the failed financial operation.
enum FinancialRecoveryDecision {
  // Retry the interrupted operation.
  retry,

  // Execute a compensating action to restore consistency.
  compensate,

  // The operation is already consistent and requires no action.
  ignore,

  // Automatic recovery is unsafe.
  //
  // The operation must be escalated to an operator.
  manualReview,

  // The failure is definitive and must not be retried.
  terminalFailure,
}
