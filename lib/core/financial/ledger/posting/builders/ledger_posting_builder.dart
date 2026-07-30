import '../../models/ledger_transaction.dart';
import '../models/posting_request.dart';
import '../templates/payment_posting_templates.dart';

class LedgerPostingBuilder {
  final PaymentPostingTemplates paymentTemplates;

  const LedgerPostingBuilder({required this.paymentTemplates});

  LedgerTransaction build(PostingRequest request) {
    _validateRequest(request);

    final transaction = paymentTemplates.build(request);

    if (!transaction.isBalanced) {
      throw StateError(
        'Posting ${request.id} generated an unbalanced '
        'ledger transaction',
      );
    }

    if (transaction.id != request.id) {
      throw StateError(
        'Generated transaction id ${transaction.id} '
        'does not match posting request id ${request.id}',
      );
    }

    if (transaction.currency.toUpperCase() != request.currency.toUpperCase()) {
      throw StateError(
        'Generated transaction currency '
        '${transaction.currency} does not match posting '
        'request currency ${request.currency}',
      );
    }

    return transaction;
  }

  void _validateRequest(PostingRequest request) {
    if (request.id.trim().isEmpty) {
      throw ArgumentError.value(
        request.id,
        'id',
        'Posting request id cannot be empty',
      );
    }

    if (request.referenceId.trim().isEmpty) {
      throw ArgumentError.value(
        request.referenceId,
        'referenceId',
        'Posting reference id cannot be empty',
      );
    }

    if (request.consultationId.trim().isEmpty) {
      throw ArgumentError.value(
        request.consultationId,
        'consultationId',
        'Consultation id cannot be empty',
      );
    }

    if (request.clientId.trim().isEmpty) {
      throw ArgumentError.value(
        request.clientId,
        'clientId',
        'Client id cannot be empty',
      );
    }

    if (request.expertId.trim().isEmpty) {
      throw ArgumentError.value(
        request.expertId,
        'expertId',
        'Expert id cannot be empty',
      );
    }

    if (request.currency.trim().isEmpty) {
      throw ArgumentError.value(
        request.currency,
        'currency',
        'Currency cannot be empty',
      );
    }

    if (request.amountMinor <= 0) {
      throw ArgumentError.value(
        request.amountMinor,
        'amountMinor',
        'Posting amount must be greater than zero',
      );
    }
  }
}
