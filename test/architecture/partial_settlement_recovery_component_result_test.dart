import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/recovery/results/'
    'partial_settlement_recovery_component_result.dart';

import 'package:mentora/core/financial/splits/models/'
    'split_destination.dart';

void main() {
  group('PartialSettlementRecoveryComponentResult', () {
    test('creates a valid component recovery result', () {
      final result = _result();

      expect(result.componentCode, 'expert_net');

      expect(result.destination, SplitDestination.expertWallet);

      expect(result.amountMinor, 8130);

      expect(result.currency, 'XOF');

      expect(result.transactionId, 'settlement_001_expert_net');

      expect(result.journalId, 'journal_settlement_001_expert_net');

      expect(
        result.action,
        PartialSettlementRecoveryComponentAction.alreadyComplete,
      );

      expect(result.metadata['source'], 'component_result_test');
    });

    test('normalizes component code and currency', () {
      final result = _result(componentCode: ' EXPERT_NET ', currency: ' xof ');

      expect(result.componentCode, 'expert_net');

      expect(result.currency, 'XOF');
    });

    test('trims transaction and journal identifiers', () {
      final result = _result(
        transactionId: ' settlement_001_expert_net ',
        journalId: ' journal_settlement_001_expert_net ',
      );

      expect(result.transactionId, 'settlement_001_expert_net');

      expect(result.journalId, 'journal_settlement_001_expert_net');
    });

    test('reports an already complete component', () {
      final result = _result(
        action: PartialSettlementRecoveryComponentAction.alreadyComplete,
      );

      expect(result.wasAlreadyComplete, isTrue);

      expect(result.wasJournalRecovered, isFalse);

      expect(result.wasComponentPosted, isFalse);
    });

    test('reports a recovered journal', () {
      final result = _result(
        action: PartialSettlementRecoveryComponentAction.journalRecovered,
      );

      expect(result.wasAlreadyComplete, isFalse);

      expect(result.wasJournalRecovered, isTrue);

      expect(result.wasComponentPosted, isFalse);
    });

    test('reports a newly posted component', () {
      final result = _result(
        action: PartialSettlementRecoveryComponentAction.componentPosted,
      );

      expect(result.wasAlreadyComplete, isFalse);

      expect(result.wasJournalRecovered, isFalse);

      expect(result.wasComponentPosted, isTrue);
    });

    test('creates serializable metadata', () {
      final result = _result(
        action: PartialSettlementRecoveryComponentAction.journalRecovered,
        metadata: const {'recoveryId': 'recovery_001', 'attempt': 2},
      );

      final metadata = result.toMetadata();

      expect(metadata['componentCode'], 'expert_net');

      expect(metadata['destination'], 'expertWallet');

      expect(metadata['amountMinor'], 8130);

      expect(metadata['currency'], 'XOF');

      expect(metadata['transactionId'], 'settlement_001_expert_net');

      expect(metadata['journalId'], 'journal_settlement_001_expert_net');

      expect(metadata['action'], 'journalRecovered');

      expect(metadata['recoveryId'], 'recovery_001');

      expect(metadata['attempt'], 2);
    });

    test('returns immutable serialized metadata', () {
      final metadata = _result().toMetadata();

      expect(() => metadata['anotherField'] = true, throwsUnsupportedError);
    });

    test('creates a defensive immutable metadata copy', () {
      final originalMetadata = <String, dynamic>{
        'source': 'automatic_recovery',
      };

      final result = _result(metadata: originalMetadata);

      originalMetadata['source'] = 'modified_source';

      originalMetadata['newField'] = true;

      expect(result.metadata['source'], 'automatic_recovery');

      expect(result.metadata.containsKey('newField'), isFalse);

      expect(() => result.metadata['another'] = true, throwsUnsupportedError);
    });

    test('copyWith preserves unchanged values', () {
      final original = _result();

      final copied = original.copyWith(
        action: PartialSettlementRecoveryComponentAction.journalRecovered,
      );

      expect(copied.componentCode, original.componentCode);

      expect(copied.destination, original.destination);

      expect(copied.amountMinor, original.amountMinor);

      expect(copied.currency, original.currency);

      expect(copied.transactionId, original.transactionId);

      expect(copied.journalId, original.journalId);

      expect(
        copied.action,
        PartialSettlementRecoveryComponentAction.journalRecovered,
      );

      expect(copied.metadata, original.metadata);

      expect(identical(copied, original), isFalse);
    });

    test('copyWith replaces supplied values', () {
      final copied = _result().copyWith(
        componentCode: 'platform_fee',
        destination: SplitDestination.platformRevenue,
        amountMinor: 1500,
        currency: 'usd',
        transactionId: 'settlement_002_platform_fee',
        journalId: 'journal_settlement_002_platform_fee',
        action: PartialSettlementRecoveryComponentAction.componentPosted,
        metadata: const {'recoveryId': 'recovery_002'},
      );

      expect(copied.componentCode, 'platform_fee');

      expect(copied.destination, SplitDestination.platformRevenue);

      expect(copied.amountMinor, 1500);

      expect(copied.currency, 'USD');

      expect(copied.transactionId, 'settlement_002_platform_fee');

      expect(copied.journalId, 'journal_settlement_002_platform_fee');

      expect(
        copied.action,
        PartialSettlementRecoveryComponentAction.componentPosted,
      );

      expect(copied.metadata['recoveryId'], 'recovery_002');
    });

    test('rejects an empty component code', () {
      expect(() => _result(componentCode: '   '), throwsArgumentError);
    });

    test('rejects an empty currency', () {
      expect(() => _result(currency: '   '), throwsArgumentError);
    });

    test('rejects an empty transaction id', () {
      expect(() => _result(transactionId: '   '), throwsArgumentError);
    });

    test('rejects an empty journal id', () {
      expect(() => _result(journalId: '   '), throwsArgumentError);
    });

    test('rejects a zero amount', () {
      expect(() => _result(amountMinor: 0), throwsArgumentError);
    });

    test('rejects a negative amount', () {
      expect(() => _result(amountMinor: -1), throwsArgumentError);
    });

    test('toString contains diagnostic information', () {
      final value = _result(
        action: PartialSettlementRecoveryComponentAction.componentPosted,
      ).toString();

      expect(value, contains('expert_net'));

      expect(value, contains('expertWallet'));

      expect(value, contains('8130'));

      expect(value, contains('XOF'));

      expect(value, contains('settlement_001_expert_net'));

      expect(value, contains('componentPosted'));
    });
  });
}

PartialSettlementRecoveryComponentResult _result({
  String componentCode = 'expert_net',
  SplitDestination destination = SplitDestination.expertWallet,
  int amountMinor = 8130,
  String currency = 'XOF',
  String transactionId = 'settlement_001_expert_net',
  String journalId = 'journal_settlement_001_expert_net',
  PartialSettlementRecoveryComponentAction action =
      PartialSettlementRecoveryComponentAction.alreadyComplete,
  Map<String, dynamic> metadata = const {'source': 'component_result_test'},
}) {
  return PartialSettlementRecoveryComponentResult(
    componentCode: componentCode,
    destination: destination,
    amountMinor: amountMinor,
    currency: currency,
    transactionId: transactionId,
    journalId: journalId,
    action: action,
    metadata: metadata,
  );
}
