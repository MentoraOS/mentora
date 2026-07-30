class MentoraConstants {
  MentoraConstants._();

  static const String appName = 'Mentora';
  static const String appTagline =
      'Transmettre le savoir. Accélérer le progrès. Construire l’avenir.';

  static const String defaultCurrency = 'XOF';
  static const String defaultCountryCode = 'ML';
  static const String defaultLanguage = 'fr';

  static const int defaultConsultationDurationMinutes = 60;
  static const int defaultPlatformCommissionPercent = 20;

  static const String bookingStatusPending = 'pending';
  static const String bookingStatusPendingPayment = 'pending_payment';
  static const String bookingStatusConfirmed = 'confirmed';
  static const String bookingStatusCompleted = 'completed';
  static const String bookingStatusCancelled = 'cancelled';

  static const String paymentStatusPending = 'pending';
  static const String paymentStatusPaid = 'paid';
  static const String paymentStatusFailed = 'failed';
  static const String paymentStatusRefunded = 'refunded';

  static const String consultationStatusScheduled = 'scheduled';
  static const String consultationStatusWaiting = 'waiting';
  static const String consultationStatusLive = 'live';
  static const String consultationStatusCompleted = 'completed';
}
