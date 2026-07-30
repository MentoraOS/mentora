import '../../chart/chart_of_accounts.dart';
import '../../models/ledger_entry.dart';
import '../../models/ledger_entry_side.dart';
import '../../models/ledger_transaction.dart';
import '../../models/ledger_transaction_status.dart';

import '../models/posting_request.dart';
import '../models/posting_type.dart';

class PaymentPostingTemplates {
  final ChartOfAccounts chartOfAccounts;

  const PaymentPostingTemplates({required this.chartOfAccounts});

  LedgerTransaction build(PostingRequest request) {
    switch (request.type) {
      case PostingType.paymentAuthorized:
        return _buildPaymentAuthorized(request);

      case PostingType.paymentMovedToEscrow:
        return _buildPaymentMovedToEscrow(request);

      case PostingType.paymentReleased:
        return _buildPaymentReleased(request);

      case PostingType.paymentRefunded:
        return _buildPaymentRefunded(request);

      case PostingType.platformCommission:
        return _buildPlatformCommission(request);

      case PostingType.taxPayable:
        return _buildTaxPayable(request);

      case PostingType.paymentProviderFee:
        return _buildPaymentProviderFee(request);

      case PostingType.affiliateCommission:
        return _buildAffiliateCommission(request);

      case PostingType.partnerCommission:
        return _buildPartnerCommission(request);

      case PostingType.walletDeposit:
      case PostingType.walletWithdrawal:
      case PostingType.walletTransfer:
        throw StateError(
          'Posting type ${request.type.name} '
          'is not handled by PaymentPostingTemplates',
        );
    }
  }

  LedgerTransaction _buildPaymentAuthorized(PostingRequest request) {
    final platformCash = chartOfAccounts.platformCash(request.currency);

    final clientWallet = chartOfAccounts.ensureClientWallet(
      clientId: request.clientId,
      currency: request.currency,
    );

    return _buildTransaction(
      request: request,
      description: 'Payment authorized',
      debitAccountId: platformCash.id,
      creditAccountId: clientWallet.id,
    );
  }

  LedgerTransaction _buildPaymentMovedToEscrow(PostingRequest request) {
    final clientWallet = chartOfAccounts.ensureClientWallet(
      clientId: request.clientId,
      currency: request.currency,
    );

    final escrow = chartOfAccounts.ensureEscrow(
      consultationId: request.consultationId,
      currency: request.currency,
    );

    return _buildTransaction(
      request: request,
      description: 'Payment moved to escrow',
      debitAccountId: clientWallet.id,
      creditAccountId: escrow.id,
    );
  }

  LedgerTransaction _buildPaymentReleased(PostingRequest request) {
    final escrow = chartOfAccounts.ensureEscrow(
      consultationId: request.consultationId,
      currency: request.currency,
    );

    final expertWallet = chartOfAccounts.ensureExpertWallet(
      expertId: request.expertId,
      currency: request.currency,
    );

    return _buildTransaction(
      request: request,
      description: 'Payment released to expert',
      debitAccountId: escrow.id,
      creditAccountId: expertWallet.id,
    );
  }

  LedgerTransaction _buildPaymentRefunded(PostingRequest request) {
    final escrow = chartOfAccounts.ensureEscrow(
      consultationId: request.consultationId,
      currency: request.currency,
    );

    final clientWallet = chartOfAccounts.ensureClientWallet(
      clientId: request.clientId,
      currency: request.currency,
    );

    return _buildTransaction(
      request: request,
      description: 'Payment refunded to client',
      debitAccountId: escrow.id,
      creditAccountId: clientWallet.id,
    );
  }

  LedgerTransaction _buildPlatformCommission(PostingRequest request) {
    final escrow = chartOfAccounts.ensureEscrow(
      consultationId: request.consultationId,
      currency: request.currency,
    );

    final commissionRevenue = chartOfAccounts.commissionRevenue(
      request.currency,
    );

    return _buildTransaction(
      request: request,
      description: 'Mentora platform commission',
      debitAccountId: escrow.id,
      creditAccountId: commissionRevenue.id,
    );
  }

  LedgerTransaction _buildTaxPayable(PostingRequest request) {
    final escrow = chartOfAccounts.ensureEscrow(
      consultationId: request.consultationId,
      currency: request.currency,
    );

    final taxPayable = chartOfAccounts.taxPayable(request.currency);

    return _buildTransaction(
      request: request,
      description: 'VAT payable',
      debitAccountId: escrow.id,
      creditAccountId: taxPayable.id,
    );
  }

  LedgerTransaction _buildPaymentProviderFee(PostingRequest request) {
    final escrow = chartOfAccounts.ensureEscrow(
      consultationId: request.consultationId,
      currency: request.currency,
    );

    final providerPayable = chartOfAccounts.paymentProviderPayable(
      request.currency,
    );

    return _buildTransaction(
      request: request,
      description: 'Payment provider fee payable',
      debitAccountId: escrow.id,
      creditAccountId: providerPayable.id,
    );
  }

  LedgerTransaction _buildAffiliateCommission(PostingRequest request) {
    final escrow = chartOfAccounts.ensureEscrow(
      consultationId: request.consultationId,
      currency: request.currency,
    );

    final affiliatePayable = chartOfAccounts.affiliatePayable(request.currency);

    return _buildTransaction(
      request: request,
      description: 'Affiliate commission payable',
      debitAccountId: escrow.id,
      creditAccountId: affiliatePayable.id,
    );
  }

  LedgerTransaction _buildPartnerCommission(PostingRequest request) {
    final escrow = chartOfAccounts.ensureEscrow(
      consultationId: request.consultationId,
      currency: request.currency,
    );

    final partnerPayable = chartOfAccounts.partnerPayable(request.currency);

    return _buildTransaction(
      request: request,
      description: 'Partner commission payable',
      debitAccountId: escrow.id,
      creditAccountId: partnerPayable.id,
    );
  }

  LedgerTransaction _buildTransaction({
    required PostingRequest request,
    required String description,
    required String debitAccountId,
    required String creditAccountId,
  }) {
    final transactionId = request.id;

    return LedgerTransaction(
      id: transactionId,

      // Un même paiement peut générer plusieurs postings.
      // Le type évite les conflits d’idempotence par referenceId.
      referenceId: '${request.type.name}:${request.referenceId}',

      description: description,
      currency: request.currency.toUpperCase(),
      status: LedgerTransactionStatus.posted,
      createdAt: request.createdAt,
      metadata: {
        ...request.metadata,
        'postingType': request.type.name,
        'businessReferenceId': request.referenceId,
        'consultationId': request.consultationId,
        'clientId': request.clientId,
        'expertId': request.expertId,
      },
      entries: [
        LedgerEntry(
          id: '${transactionId}_debit',
          transactionId: transactionId,
          accountId: debitAccountId,
          amountMinor: request.amountMinor,
          currency: request.currency.toUpperCase(),
          side: LedgerEntrySide.debit,
          createdAt: request.createdAt,
        ),
        LedgerEntry(
          id: '${transactionId}_credit',
          transactionId: transactionId,
          accountId: creditAccountId,
          amountMinor: request.amountMinor,
          currency: request.currency.toUpperCase(),
          side: LedgerEntrySide.credit,
          createdAt: request.createdAt,
        ),
      ],
    );
  }
}
