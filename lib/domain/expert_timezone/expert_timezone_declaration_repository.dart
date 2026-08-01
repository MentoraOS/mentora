/// Port for the expert's declared timezone identity (AD-022 Clarification A).
///
/// Expert Catalog owns the declared identity as expert profile/context data;
/// this port is the expert-side write boundary for that declaration. The
/// identity is a named timezone string, stored verbatim. It is never derived
/// from a country: only an explicit expert confirmation reaches [save].
abstract interface class ExpertTimezoneDeclarationRepository {
  /// The currently declared identity, or `null` when the expert has not
  /// declared one yet.
  Future<String?> loadByExpertId(String expertId);

  Future<void> saveByExpertId({
    required String expertId,
    required String timezone,
  });
}

final class ExpertTimezoneRepositoryException implements Exception {
  const ExpertTimezoneRepositoryException({required this.cause});

  final Object cause;

  @override
  String toString() => 'ExpertTimezoneRepositoryException: $cause';
}
