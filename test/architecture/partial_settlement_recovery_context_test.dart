import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/recovery/contexts/'
    'partial_settlement_recovery_context.dart';
import 'package:mentora/core/financial/splits/models/'
    'settlement_split.dart';

import 'package:mentora/core/financial/splits/models/'
    'settlement_split_component.dart';

import 'package:mentora/core/financial/splits/models/'
    'split_destination.dart';

void main() {
  group('PartialSettlementRecoveryContext', () {
    test('creates an immutable recovery context', () {
      final context = _context();

      expect(context.operationId, 'settlement_001');

      expect(context.consultationId, 'consultation_001');

      expect(context.escrowId, 'escrow_001');

      expect(context.clientId, 'client_001');

      expect(context.expertId, 'expert_001');

      expect(context.currency, 'XOF');

      expect(context.totalMinor, 10000);

      expect(context.componentCount, 4);

      expect(context.hasComponents, isTrue);

      expect(context.metadata['origin'], 'integration_test');
    });

    test('builds deterministic transaction identifiers', () {
      final context = _context();

      expect(
        context.transactionIdForComponentCode('expert_net'),
        'settlement_001_expert_net',
      );

      expect(
        context.transactionIdForComponentCode('platform_fee'),
        'settlement_001_platform_fee',
      );

      expect(
        context.transactionIdForComponentCode('tax'),
        'settlement_001_tax',
      );

      expect(
        context.transactionIdForComponentCode('provider_fee'),
        'settlement_001_provider_fee',
      );
    });

    test('returns every expected transaction identifier', () {
      final context = _context();

      expect(context.expectedTransactionIds, [
        'settlement_001_expert_net',
        'settlement_001_platform_fee',
        'settlement_001_tax',
        'settlement_001_provider_fee',
      ]);
    });

    test('copyWith preserves immutable values', () {
      final context = _context();

      final copy = context.copyWith();

      expect(identical(copy, context), isFalse);

      expect(copy.operationId, context.operationId);

      expect(copy.expectedTransactionIds, context.expectedTransactionIds);

      expect(copy.metadata, context.metadata);
    });

    test('copyWith replaces selected values', () {
      final updated = _context().copyWith(
        operationId: 'settlement_002',
        consultationId: 'consultation_002',
      );

      expect(updated.operationId, 'settlement_002');

      expect(updated.consultationId, 'consultation_002');

      expect(
        updated.transactionIdForComponentCode('expert_net'),
        'settlement_002_expert_net',
      );
    });

    test('normalizes identifiers', () {
      final context = _context(operationId: ' settlement_001 ');

      expect(context.operationId, 'settlement_001');
    });

    test('rejects empty operation id', () {
      expect(() => _context(operationId: ''), throwsArgumentError);
    });

    test('rejects duplicate split component codes', () {
      expect(() => _duplicateComponentContext(), throwsStateError);
    });

    test('rejects empty component code', () {
      expect(() => _emptyComponentCodeContext(), throwsArgumentError);
    });

    test('rejects non positive component amount', () {
      expect(() => _zeroAmountContext(), throwsArgumentError);
    });

    test('normalizes occurredAt to utc', () {
      final localDate = DateTime(2026, 7, 16, 10);

      final context = _context(occurredAt: localDate);

      expect(context.occurredAt.isUtc, isTrue);

      expect(context.occurredAt, localDate.toUtc());
    });

    test('creates an immutable defensive metadata copy', () {
      final metadata = <String, dynamic>{'origin': 'automatic_recovery'};

      final context = _context(metadata: metadata);

      metadata['origin'] = 'modified';
      metadata['newField'] = true;

      expect(context.metadata['origin'], 'automatic_recovery');

      expect(context.metadata.containsKey('newField'), isFalse);

      expect(() => context.metadata['another'] = true, throwsUnsupportedError);
    });
  });
}

PartialSettlementRecoveryContext _context({
  String operationId = 'settlement_001',
  String consultationId = 'consultation_001',
  String escrowId = 'escrow_001',
  String clientId = 'client_001',
  String expertId = 'expert_001',
  SettlementSplit? split,
  DateTime? occurredAt,
  Map<String, dynamic> metadata = const {'origin': 'integration_test'},
}) {
  return PartialSettlementRecoveryContext(
    operationId: operationId,
    consultationId: consultationId,
    escrowId: escrowId,
    clientId: clientId,
    expertId: expertId,
    split: split ?? _validSplit(),
    occurredAt: occurredAt ?? DateTime.utc(2026, 7, 16, 10),
    metadata: metadata,
  );
}

SettlementSplit _validSplit() {
  return const SettlementSplit(
    grossAmountMinor: 10000,
    currency: 'XOF',
    components: [
      SettlementSplitComponent(
        destination: SplitDestination.expertWallet,
        amountMinor: 8130,
        code: 'expert_net',
        label: 'Expert net amount',
      ),
      SettlementSplitComponent(
        destination: SplitDestination.platformRevenue,
        amountMinor: 1500,
        code: 'platform_fee',
        label: 'Platform commission',
      ),
      SettlementSplitComponent(
        destination: SplitDestination.taxPayable,
        amountMinor: 270,
        code: 'tax',
        label: 'Tax payable',
      ),
      SettlementSplitComponent(
        destination: SplitDestination.paymentProviderFee,
        amountMinor: 100,
        code: 'provider_fee',
        label: 'Payment provider fee',
      ),
    ],
  );
}

PartialSettlementRecoveryContext _duplicateComponentContext() {
  return _context(
    split: const SettlementSplit(
      grossAmountMinor: 10000,
      currency: 'XOF',
      components: [
        SettlementSplitComponent(
          destination: SplitDestination.expertWallet,
          amountMinor: 8000,
          code: 'expert_net',
          label: 'Expert net amount',
        ),
        SettlementSplitComponent(
          destination: SplitDestination.platformRevenue,
          amountMinor: 2000,
          code: ' EXPERT_NET ',
          label: 'Duplicate component code',
        ),
      ],
    ),
  );
}

PartialSettlementRecoveryContext _emptyComponentCodeContext() {
  /*
   * SettlementSplitComponent possède un assert(code != '').
   * Pour tester la validation métier du RecoveryContext plutôt que
   * l’assertion du modèle, on utilise une chaîne composée d’espaces.
   */
  return _context(
    split: const SettlementSplit(
      grossAmountMinor: 10000,
      currency: 'XOF',
      components: [
        SettlementSplitComponent(
          destination: SplitDestination.expertWallet,
          amountMinor: 10000,
          code: '   ',
          label: 'Invalid empty code',
        ),
      ],
    ),
  );
}

PartialSettlementRecoveryContext _zeroAmountContext() {
  return _context(
    split: const SettlementSplit(
      grossAmountMinor: 0,
      currency: 'XOF',
      components: [
        SettlementSplitComponent(
          destination: SplitDestination.expertWallet,
          amountMinor: 0,
          code: 'expert_net',
          label: 'Expert net amount',
        ),
      ],
    ),
  );
}
