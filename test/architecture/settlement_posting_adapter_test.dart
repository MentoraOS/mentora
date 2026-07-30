import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/settlement/settlements.dart';
import 'package:mentora/core/financial/domain/shared/money/financial_currency.dart';
import 'package:mentora/core/financial/domain/shared/money/money.dart';

import 'package:mentora/core/financial/ledger/models/ledger_entry.dart';
import 'package:mentora/core/financial/ledger/models/ledger_entry_side.dart';
import 'package:mentora/core/financial/ledger/models/ledger_transaction.dart';
import 'package:mentora/core/financial/ledger/models/'
    'ledger_transaction_status.dart';
import 'package:mentora/core/financial/ledger/posting/models/'
    'posting_request.dart';
import 'package:mentora/core/financial/ledger/posting/models/'
    'posting_type.dart';

import 'package:mentora/core/financial/orchestrator/adapters/'
    'settlement_posting_adapter.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/models/settlement_posting_category.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/models/settlement_posting_instruction.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/models/settlement_posting_line.dart';

void main() {
  group('SettlementPostingAdapter', () {
    late List<PostingRequest> capturedRequests;
    late SettlementPostingAdapter adapter;

    setUp(() {
      capturedRequests = <PostingRequest>[];

      adapter = SettlementPostingAdapter(
        post: (request) async {
          capturedRequests.add(request);

          return LedgerTransaction(
            id: request.id,
            referenceId: '${request.type.name}:${request.referenceId}',
            description: request.type.name,
            currency: request.currency.toUpperCase(),
            status: LedgerTransactionStatus.posted,
            createdAt: request.createdAt,
            metadata: request.metadata,
            entries: <LedgerEntry>[
              LedgerEntry(
                id: '${request.id}_debit',
                transactionId: request.id,
                accountId: 'test_debit_account',
                amountMinor: request.amountMinor,
                currency: request.currency.toUpperCase(),
                side: LedgerEntrySide.debit,
                createdAt: request.createdAt,
              ),
              LedgerEntry(
                id: '${request.id}_credit',
                transactionId: request.id,
                accountId: 'test_credit_account',
                amountMinor: request.amountMinor,
                currency: request.currency.toUpperCase(),
                side: LedgerEntrySide.credit,
                createdAt: request.createdAt,
              ),
            ],
          );
        },
      );
    });

    test('should post every settlement instruction line', () async {
      final receipt = await adapter.postSettlement(
        instruction: _buildInstruction(),
      );

      expect(capturedRequests.length, 4);
      expect(receipt.ledgerTransactionIds.length, 4);
      expect(receipt.operationId, 'settlement_001');
    });

    test('should map posting categories to posting types', () async {
      await adapter.postSettlement(instruction: _buildInstruction());

      expect(
        capturedRequests.map((request) => request.type),
        containsAll(<PostingType>[
          PostingType.paymentReleased,
          PostingType.platformCommission,
          PostingType.taxPayable,
          PostingType.paymentProviderFee,
        ]),
      );
    });

    test('should preserve every posting line amount', () async {
      await adapter.postSettlement(instruction: _buildInstruction());

      final amounts = <PostingType, int>{
        for (final request in capturedRequests)
          request.type: request.amountMinor,
      };

      expect(amounts[PostingType.paymentReleased], 8130);
      expect(amounts[PostingType.platformCommission], 1500);
      expect(amounts[PostingType.taxPayable], 270);
      expect(amounts[PostingType.paymentProviderFee], 100);
    });

    test('should use deterministic posting identifiers', () async {
      await adapter.postSettlement(instruction: _buildInstruction());

      expect(capturedRequests.map((request) => request.id).toSet(), <String>{
        'settlement_001_expert_net',
        'settlement_001_platform_fee',
        'settlement_001_vat',
        'settlement_001_payment_provider_fee',
      });
    });

    test('should preserve instruction metadata', () async {
      await adapter.postSettlement(instruction: _buildInstruction());

      for (final request in capturedRequests) {
        expect(request.metadata['source'], 'settlement_posting_adapter_test');
        expect(request.metadata['settlementId'], 'settlement_001');
      }
    });

    test('should preserve orchestration identifiers', () async {
      await adapter.postSettlement(instruction: _buildInstruction());

      for (final request in capturedRequests) {
        expect(request.referenceId, 'settlement_001');
        expect(request.consultationId, 'consultation_001');
        expect(request.clientId, 'client_001');
        expect(request.expertId, 'expert_001');
        expect(request.metadata['escrowId'], 'escrow_001');
      }
    });

    test('should reject an instruction with zero total', () {
      final instruction = SettlementPostingInstruction(
        settlementId: SettlementId('settlement_zero'),
        operationId: 'settlement_zero',
        consultationId: 'consultation_001',
        escrowId: 'escrow_001',
        clientId: 'client_001',
        expertId: 'expert_001',
        lines: <SettlementPostingLine>[
          SettlementPostingLine(
            party: SettlementParty.expert,
            category: SettlementPostingCategory.expertRevenue,
            amount: Money(minorUnits: 0, currency: FinancialCurrency.xof),
            code: 'EXPERT_NET',
            label: 'Expert net amount',
          ),
        ],
        occurredAt: DateTime.utc(2026, 7, 12, 10),
      );

      expect(
        () => adapter.postSettlement(instruction: instruction),
        throwsStateError,
      );

      expect(capturedRequests, isEmpty);
    });

    test(
      'should map affiliate commission to affiliate commission posting type',
      () async {
        final instruction = SettlementPostingInstruction(
          settlementId: SettlementId('settlement_affiliate'),
          operationId: 'settlement_affiliate',
          consultationId: 'consultation_001',
          escrowId: 'escrow_001',
          clientId: 'client_001',
          expertId: 'expert_001',
          occurredAt: DateTime.utc(2026, 7, 12, 10),
          lines: <SettlementPostingLine>[
            SettlementPostingLine(
              party: SettlementParty.expert,
              category: SettlementPostingCategory.affiliateCommission,
              amount: Money(minorUnits: 500, currency: FinancialCurrency.xof),
              code: 'AFFILIATE_COMMISSION',
              label: 'Affiliate commission',
            ),
          ],
        );

        await adapter.postSettlement(instruction: instruction);

        expect(capturedRequests, hasLength(1));
        expect(capturedRequests.single.type, PostingType.affiliateCommission);
      },
    );

    test(
      'should map partner commission to partner commission posting type',
      () async {
        final instruction = SettlementPostingInstruction(
          settlementId: SettlementId('settlement_partner'),
          operationId: 'settlement_partner',
          consultationId: 'consultation_001',
          escrowId: 'escrow_001',
          clientId: 'client_001',
          expertId: 'expert_001',
          occurredAt: DateTime.utc(2026, 7, 12, 10),
          lines: <SettlementPostingLine>[
            SettlementPostingLine(
              party: SettlementParty.expert,
              category: SettlementPostingCategory.partnerCommission,
              amount: Money(minorUnits: 700, currency: FinancialCurrency.xof),
              code: 'PARTNER_COMMISSION',
              label: 'Partner commission',
            ),
          ],
        );

        await adapter.postSettlement(instruction: instruction);

        expect(capturedRequests, hasLength(1));
        expect(capturedRequests.single.type, PostingType.partnerCommission);
      },
    );
  });
}

SettlementPostingInstruction _buildInstruction() {
  return SettlementPostingInstruction(
    settlementId: SettlementId('settlement_001'),
    operationId: 'settlement_001',
    consultationId: 'consultation_001',
    escrowId: 'escrow_001',
    clientId: 'client_001',
    expertId: 'expert_001',
    occurredAt: DateTime.utc(2026, 7, 12, 10),
    metadata: const <String, Object?>{
      'source': 'settlement_posting_adapter_test',
    },
    lines: <SettlementPostingLine>[
      SettlementPostingLine(
        party: SettlementParty.expert,
        category: SettlementPostingCategory.expertRevenue,
        amount: Money(minorUnits: 8130, currency: FinancialCurrency.xof),
        code: 'EXPERT_NET',
        label: 'Expert net amount',
      ),
      SettlementPostingLine(
        party: SettlementParty.platform,
        category: SettlementPostingCategory.platformRevenue,
        amount: Money(minorUnits: 1500, currency: FinancialCurrency.xof),
        code: 'PLATFORM_FEE',
        label: 'Platform revenue',
      ),
      SettlementPostingLine(
        party: SettlementParty.tax,
        category: SettlementPostingCategory.taxPayable,
        amount: Money(minorUnits: 270, currency: FinancialCurrency.xof),
        code: 'VAT',
        label: 'VAT payable',
      ),
      SettlementPostingLine(
        party: SettlementParty.paymentProvider,
        category: SettlementPostingCategory.paymentProviderFee,
        amount: Money(minorUnits: 100, currency: FinancialCurrency.xof),
        code: 'PAYMENT_PROVIDER_FEE',
        label: 'Payment provider fee',
      ),
    ],
  );
}
