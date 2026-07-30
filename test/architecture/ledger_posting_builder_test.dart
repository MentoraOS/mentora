import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/chart/account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/chart_of_accounts.dart';
import 'package:mentora/core/financial/ledger/posting/builders/ledger_posting_builder.dart';
import 'package:mentora/core/financial/ledger/posting/models/posting_request.dart';
import 'package:mentora/core/financial/ledger/posting/models/posting_type.dart';
import 'package:mentora/core/financial/ledger/posting/templates/payment_posting_templates.dart';

void main() {
  group('LedgerPostingBuilder', () {
    late AccountRegistry registry;
    late ChartOfAccounts chartOfAccounts;
    late PaymentPostingTemplates templates;
    late LedgerPostingBuilder builder;

    setUp(() {
      registry = AccountRegistry();

      chartOfAccounts = ChartOfAccounts(registry: registry);

      chartOfAccounts.initializeCurrency('USD');

      templates = PaymentPostingTemplates(chartOfAccounts: chartOfAccounts);

      builder = LedgerPostingBuilder(paymentTemplates: templates);
    });

    test('should build a balanced ledger transaction', () {
      final request = _buildRequest();

      final transaction = builder.build(request);

      expect(transaction.id, request.id);

      expect(transaction.currency, 'USD');

      expect(transaction.entries.length, 2);

      expect(transaction.isBalanced, isTrue);
    });

    test('should preserve posting metadata', () {
      final request = _buildRequest();

      final transaction = builder.build(request);

      expect(transaction.metadata['clientId'], request.clientId);

      expect(transaction.metadata['expertId'], request.expertId);

      expect(transaction.metadata['consultationId'], request.consultationId);

      expect(transaction.metadata['postingType'], request.type.name);
    });

    test('should reject empty request id', () {
      expect(() => builder.build(_buildRequest(id: '')), throwsArgumentError);
    });

    test('should reject zero amount', () {
      expect(
        () => builder.build(_buildRequest(amountMinor: 0)),
        throwsArgumentError,
      );
    });

    test('should reject empty currency', () {
      expect(
        () => builder.build(_buildRequest(currency: '')),
        throwsArgumentError,
      );
    });

    test('should reject empty client id', () {
      expect(
        () => builder.build(_buildRequest(clientId: '')),
        throwsArgumentError,
      );
    });

    test('should reject empty expert id', () {
      expect(
        () => builder.build(_buildRequest(expertId: '')),
        throwsArgumentError,
      );
    });
  });
}

PostingRequest _buildRequest({
  String id = 'posting_001',
  String referenceId = 'payment_001',
  PostingType type = PostingType.paymentAuthorized,
  String consultationId = 'consultation_001',
  String clientId = 'client_001',
  String expertId = 'expert_001',
  int amountMinor = 6000,
  String currency = 'USD',
}) {
  return PostingRequest(
    id: id,
    referenceId: referenceId,
    type: type,
    consultationId: consultationId,
    clientId: clientId,
    expertId: expertId,
    amountMinor: amountMinor,
    currency: currency,
    createdAt: DateTime.utc(2026, 7, 10),
  );
}
