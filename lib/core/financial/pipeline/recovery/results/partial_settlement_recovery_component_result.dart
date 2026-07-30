import '../../../splits/models/split_destination.dart';

/// Action réellement effectuée pour remettre un composant du settlement
/// dans un état comptable complet.
enum PartialSettlementRecoveryComponentAction {
  /// La transaction et son journal étaient déjà correctement postés.
  alreadyComplete,

  /// La transaction existait, mais son journal était absent ou pending.
  journalRecovered,

  /// La transaction n’existait pas et le composant a été posté.
  componentPosted,
}

/// Résultat immuable de la récupération d’un composant du settlement.
///
/// Un settlement peut produire plusieurs composants comptables indépendants.
/// Ce modèle permet au moteur de conserver une trace exacte de l’action
/// effectuée sur chacun d’eux.
final class PartialSettlementRecoveryComponentResult {
  PartialSettlementRecoveryComponentResult({
    required String componentCode,
    required this.destination,
    required int amountMinor,
    required String currency,
    required String transactionId,
    required String journalId,
    required this.action,
    Map<String, dynamic> metadata = const {},
  }) : componentCode = _normalizeRequired(
         componentCode,
         'componentCode',
       ).toLowerCase(),
       amountMinor = _validateAmount(amountMinor),
       currency = _normalizeRequired(currency, 'currency').toUpperCase(),
       transactionId = _normalizeRequired(transactionId, 'transactionId'),
       journalId = _normalizeRequired(journalId, 'journalId'),
       metadata = Map.unmodifiable(Map<String, dynamic>.from(metadata));

  /// Code déterministe du composant provenant du SettlementSplit.
  final String componentCode;

  final SplitDestination destination;

  final int amountMinor;

  final String currency;

  /// Identifiant déterministe de la LedgerTransaction.
  final String transactionId;

  /// Identifiant déterministe du LedgerJournal correspondant.
  final String journalId;

  final PartialSettlementRecoveryComponentAction action;

  final Map<String, dynamic> metadata;

  bool get wasAlreadyComplete =>
      action == PartialSettlementRecoveryComponentAction.alreadyComplete;

  bool get wasJournalRecovered =>
      action == PartialSettlementRecoveryComponentAction.journalRecovered;

  bool get wasComponentPosted =>
      action == PartialSettlementRecoveryComponentAction.componentPosted;

  /// Représentation sérialisable destinée aux métadonnées du résultat global.
  Map<String, dynamic> toMetadata() {
    return Map.unmodifiable({
      'componentCode': componentCode,
      'destination': destination.name,
      'amountMinor': amountMinor,
      'currency': currency,
      'transactionId': transactionId,
      'journalId': journalId,
      'action': action.name,
      ...metadata,
    });
  }

  PartialSettlementRecoveryComponentResult copyWith({
    String? componentCode,
    SplitDestination? destination,
    int? amountMinor,
    String? currency,
    String? transactionId,
    String? journalId,
    PartialSettlementRecoveryComponentAction? action,
    Map<String, dynamic>? metadata,
  }) {
    return PartialSettlementRecoveryComponentResult(
      componentCode: componentCode ?? this.componentCode,
      destination: destination ?? this.destination,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      transactionId: transactionId ?? this.transactionId,
      journalId: journalId ?? this.journalId,
      action: action ?? this.action,
      metadata: metadata ?? this.metadata,
    );
  }

  static int _validateAmount(int value) {
    if (value <= 0) {
      throw ArgumentError.value(
        value,
        'amountMinor',
        'Component recovery amount must be greater than zero.',
      );
    }

    return value;
  }

  static String _normalizeRequired(String value, String fieldName) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName must not be empty.',
      );
    }

    return normalized;
  }

  @override
  String toString() {
    return 'PartialSettlementRecoveryComponentResult('
        'componentCode: $componentCode, '
        'destination: ${destination.name}, '
        'amountMinor: $amountMinor, '
        'currency: $currency, '
        'transactionId: $transactionId, '
        'journalId: $journalId, '
        'action: ${action.name}'
        ')';
  }
}
