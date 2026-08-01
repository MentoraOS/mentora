import '../../domain/expert_timezone/expert_timezone_declaration_repository.dart';
import '../authentication/authentication_session.dart';
import 'expert_timezone_failure.dart';

/// Expert-side declaration of the authoritative timezone identity.
///
/// AD-022 Clarification A: before an expert can expose reservable canonical
/// occurrences, an authoritative `expertTimezone` must exist. This service
/// records the expert's EXPLICIT confirmation. Country may only assist as a
/// UI suggestion; nothing here ever derives or persists an identity without
/// that explicit declaration, and an unsupported identity fails closed.
final class ExpertTimezoneApplicationService {
  const ExpertTimezoneApplicationService({
    required AuthenticationSession session,
    required ExpertTimezoneDeclarationRepository repository,
  }) : _session = session,
       _repository = repository;

  final AuthenticationSession _session;
  final ExpertTimezoneDeclarationRepository _repository;

  /// Launch-market identities supported by the production resolver.
  ///
  /// Offering an identity the platform cannot interpret would only recreate
  /// the fail-closed dead end downstream, so the choice is restricted here.
  static const List<String> supportedTimezones = [
    'Africa/Bamako',
    'Africa/Dakar',
    'Africa/Abidjan',
  ];

  /// The expert's currently declared identity, or `null` when absent.
  Future<String?> loadCurrentTimezone() {
    final expertId = _requireCurrentExpertId();
    return _translate(() => _repository.loadByExpertId(expertId));
  }

  /// Records the expert's explicit timezone confirmation.
  Future<void> declareTimezone(String timezone) {
    final expertId = _requireCurrentExpertId();

    if (!supportedTimezones.contains(timezone)) {
      throw ExpertTimezoneUnsupportedFailure(timezone);
    }

    return _translate(
      () => _repository.saveByExpertId(expertId: expertId, timezone: timezone),
    );
  }

  String _requireCurrentExpertId() {
    final expertId = _session.currentUserId?.trim();

    if (!_session.isAuthenticated || expertId == null || expertId.isEmpty) {
      throw const ExpertTimezoneUnauthenticatedFailure();
    }

    if (!_session.isExpert) {
      throw const ExpertTimezoneForbiddenFailure();
    }

    return expertId;
  }

  Future<T> _translate<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on ExpertTimezoneRepositoryException catch (error) {
      throw ExpertTimezoneRepositoryFailure(cause: error.cause);
    } on ExpertTimezoneFailure {
      rethrow;
    } catch (error) {
      throw ExpertTimezoneRepositoryFailure(cause: error);
    }
  }
}
