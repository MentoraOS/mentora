/// One expert unavailability window: a blocked day, a multi-day block, a
/// holiday or an exceptional absence. Whole civil days only.
final class ExpertAvailabilityException {
  final String id;
  final String expertId;

  /// Inclusive civil dates, strict `YYYY-MM-DD`.
  final String startDate;
  final String endDate;
  final String reason;

  factory ExpertAvailabilityException({
    required String id,
    required String expertId,
    required String startDate,
    required String endDate,
    required String reason,
  }) {
    if (!isValidDate(startDate)) {
      throw ArgumentError.value(startDate, 'startDate', 'must be YYYY-MM-DD');
    }
    if (!isValidDate(endDate)) {
      throw ArgumentError.value(endDate, 'endDate', 'must be YYYY-MM-DD');
    }
    if (endDate.compareTo(startDate) < 0) {
      throw ArgumentError.value(endDate, 'endDate', 'must not precede start');
    }
    if (reason.trim().isEmpty) {
      throw ArgumentError.value(reason, 'reason', 'must not be empty');
    }

    return ExpertAvailabilityException._(
      id: id,
      expertId: expertId,
      startDate: startDate,
      endDate: endDate,
      reason: reason.trim(),
    );
  }

  const ExpertAvailabilityException._({
    required this.id,
    required this.expertId,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  static final RegExp _dateSyntax = RegExp(r'^[0-9]{4}-[0-9]{2}-[0-9]{2}$');

  static bool isValidDate(String value) => _dateSyntax.hasMatch(value);

  /// Whether the civil date `YYYY-MM-DD` falls inside this window.
  bool blocksDate(String date) {
    return startDate.compareTo(date) <= 0 && date.compareTo(endDate) <= 0;
  }
}

/// Port persisting expert unavailability windows in their own collection —
/// the expert document and the recurring availability are never touched.
abstract interface class ExpertAvailabilityExceptionRepository {
  Future<void> create({
    required String expertId,
    required String startDate,
    required String endDate,
    required String reason,
  });

  Future<List<ExpertAvailabilityException>> listByExpertId(String expertId);

  /// Deletes the expert's own exception; a foreign or unknown id throws
  /// [ExpertAvailabilityExceptionNotFoundException].
  Future<void> delete({required String id, required String expertId});
}

final class ExpertAvailabilityExceptionNotFoundException implements Exception {
  const ExpertAvailabilityExceptionNotFoundException();
}

final class ExpertAvailabilityExceptionRepositoryException
    implements Exception {
  const ExpertAvailabilityExceptionRepositoryException({required this.cause});

  final Object cause;
}
