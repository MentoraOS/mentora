enum AuditAction {
  userCreated,
  userUpdated,
  userDeleted,

  expertCreated,
  expertVerified,
  expertSuspended,

  bookingCreated,
  bookingCancelled,
  bookingCompleted,

  paymentCreated,
  paymentSucceeded,
  paymentFailed,
  paymentRefunded,

  countryConfigUpdated,
  featureFlagUpdated,

  aiSummaryGenerated,
}
