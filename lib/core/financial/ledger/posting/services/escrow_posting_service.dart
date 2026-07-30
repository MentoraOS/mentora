import '../../../../escrow/models/escrow.dart';
import '../engine/posting_engine.dart';
import '../models/posting_request.dart';
import '../models/posting_type.dart';

class EscrowPostingService {
  final PostingEngine postingEngine;

  const EscrowPostingService({required this.postingEngine});

  /// Déplace les fonds du wallet client vers l’escrow.
  Future<void> onLocked({
    required Escrow escrow,
    required int amountMinor,
    required DateTime occurredAt,
  }) async {
    await postingEngine.post(
      _buildRequest(
        escrow: escrow,
        amountMinor: amountMinor,
        occurredAt: occurredAt,
        operation: 'locked',
        type: PostingType.paymentMovedToEscrow,
      ),
    );
  }

  /// Déplace les fonds de l’escrow vers le wallet expert.
  Future<void> onReleased({
    required Escrow escrow,
    required int amountMinor,
    required DateTime occurredAt,
  }) async {
    await postingEngine.post(
      _buildRequest(
        escrow: escrow,
        amountMinor: amountMinor,
        occurredAt: occurredAt,
        operation: 'released',
        type: PostingType.paymentReleased,
      ),
    );
  }

  /// Retourne les fonds de l’escrow vers le wallet client.
  Future<void> onRefunded({
    required Escrow escrow,
    required int amountMinor,
    required DateTime occurredAt,
  }) async {
    await postingEngine.post(
      _buildRequest(
        escrow: escrow,
        amountMinor: amountMinor,
        occurredAt: occurredAt,
        operation: 'refunded',
        type: PostingType.paymentRefunded,
      ),
    );
  }

  /// Une annulation depuis pending ne génère aucune écriture comptable,
  /// car les fonds ne sont pas encore entrés dans l’escrow.
  Future<void> onCancelled({
    required Escrow escrow,
    required DateTime occurredAt,
  }) async {
    // Intentionnellement vide.
    //
    // Nous gardons cette méthode afin que l’EscrowEngine dispose d’une
    // interface uniforme pour toutes les transitions terminales.
    //
    // Si une annulation après mouvement financier devient nécessaire,
    // elle devra être représentée par un posting de remboursement explicite.
  }

  PostingRequest _buildRequest({
    required Escrow escrow,
    required int amountMinor,
    required DateTime occurredAt,
    required String operation,
    required PostingType type,
  }) {
    if (amountMinor <= 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'Escrow posting amount must be greater than zero',
      );
    }

    final normalizedOccurredAt = occurredAt.toUtc();

    return PostingRequest(
      // Identifiant stable : indispensable pour l’idempotence.
      id: 'escrow_${escrow.id}_$operation',

      // Un paiement peut produire lock, release et refund.
      // PostingType sera également ajouté par le template.
      referenceId: escrow.paymentId,

      type: type,
      consultationId: escrow.consultationId,
      clientId: escrow.payerId,
      expertId: escrow.receiverId,
      amountMinor: amountMinor,
      currency: escrow.currency.toUpperCase(),
      createdAt: normalizedOccurredAt,
      metadata: {
        'source': 'escrow',
        'escrowId': escrow.id,
        'escrowOperation': operation,
        'paymentId': escrow.paymentId,
        'consultationId': escrow.consultationId,
      },
    );
  }
}
