import 'posting_type.dart';

class PostingRequest {
  final String id;

  /// Identifiant métier
  /// (paymentId, refundId, payoutId...)
  final String referenceId;

  final PostingType type;

  final String consultationId;

  final String clientId;

  final String expertId;

  final int amountMinor;

  final String currency;

  final DateTime createdAt;

  final Map<String, dynamic> metadata;

  const PostingRequest({
    required this.id,
    required this.referenceId,
    required this.type,
    required this.consultationId,
    required this.clientId,
    required this.expertId,
    required this.amountMinor,
    required this.currency,
    required this.createdAt,
    this.metadata = const {},
  });
}
