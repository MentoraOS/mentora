import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/settlement/settlements.dart';
import 'package:mentora/core/financial/domain/shared/money/financial_currency.dart';
import 'package:mentora/core/financial/domain/shared/money/money.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/models/settlement_posting_instruction.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/models/settlement_posting_line.dart';
import 'package:mentora/core/financial/orchestrator/workflows/financial_posting/models/settlement_posting_category.dart';

void main() {
  group('SettlementPostingInstruction', () {
    final occurredAt = DateTime.utc(2026, 7, 18, 12);

    SettlementPostingLine createLine({
      SettlementParty party = SettlementParty.expert,
      SettlementPostingCategory category =
          SettlementPostingCategory.expertRevenue,
      int minorUnits = 8500,
      FinancialCurrency currency = FinancialCurrency.xof,
      String code = 'EXPERT_REVENUE',
      String label = 'Expert revenue',
    }) {
      return SettlementPostingLine(
        party: party,
        category: category,
        amount: Money(minorUnits: minorUnits, currency: currency),
        code: code,
        label: label,
      );
    }

    SettlementPostingInstruction createInstruction({
      List<SettlementPostingLine>? lines,
      Map<String, Object?> metadata = const <String, Object?>{
        'source': 'consultation-settlement',
      },
    }) {
      return SettlementPostingInstruction(
        settlementId: SettlementId('settlement_001'),
        operationId: 'operation_001',
        consultationId: 'consultation_001',
        escrowId: 'escrow_001',
        clientId: 'client_001',
        expertId: 'expert_001',
        lines:
            lines ??
            <SettlementPostingLine>[
              createLine(),
              createLine(
                party: SettlementParty.platform,
                category: SettlementPostingCategory.platformRevenue,
                minorUnits: 1500,
                code: 'PLATFORM_REVENUE',
                label: 'Platform revenue',
              ),
            ],
        occurredAt: occurredAt,
        metadata: metadata,
      );
    }

    test('creates a valid posting instruction', () {
      final instruction = createInstruction();

      expect(instruction.settlementId.value, 'settlement_001');
      expect(instruction.operationId, 'operation_001');
      expect(instruction.consultationId, 'consultation_001');
      expect(instruction.escrowId, 'escrow_001');
      expect(instruction.clientId, 'client_001');
      expect(instruction.expertId, 'expert_001');
      expect(instruction.lineCount, 2);
      expect(instruction.isEmpty, isFalse);
      expect(instruction.isNotEmpty, isTrue);
      expect(instruction.currency, FinancialCurrency.xof);
      expect(instruction.totalMinorUnits, 10000);
      expect(instruction.total.minorUnits, 10000);
      expect(instruction.total.currency, FinancialCurrency.xof);
      expect(instruction.occurredAt, occurredAt);
      expect(instruction.metadata['source'], 'consultation-settlement');
    });

    test('normalizes all required identifiers', () {
      final instruction = SettlementPostingInstruction(
        settlementId: SettlementId('settlement_001'),
        operationId: '  operation_001  ',
        consultationId: '  consultation_001  ',
        escrowId: '  escrow_001  ',
        clientId: '  client_001  ',
        expertId: '  expert_001  ',
        lines: <SettlementPostingLine>[createLine(minorUnits: 10000)],
        occurredAt: occurredAt,
      );

      expect(instruction.operationId, 'operation_001');
      expect(instruction.consultationId, 'consultation_001');
      expect(instruction.escrowId, 'escrow_001');
      expect(instruction.clientId, 'client_001');
      expect(instruction.expertId, 'expert_001');
    });

    test('stores lines as an unmodifiable list', () {
      final sourceLines = <SettlementPostingLine>[
        createLine(minorUnits: 10000),
      ];

      final instruction = createInstruction(lines: sourceLines);

      expect(
        () => instruction.lines.add(createLine(minorUnits: 1)),
        throwsUnsupportedError,
      );

      sourceLines.add(createLine(minorUnits: 500));

      expect(instruction.lineCount, 1);
    });

    test('stores metadata as an unmodifiable map', () {
      final sourceMetadata = <String, Object?>{'source': 'test'};

      final instruction = createInstruction(metadata: sourceMetadata);

      expect(
        () => instruction.metadata['newKey'] = 'value',
        throwsUnsupportedError,
      );

      sourceMetadata['source'] = 'changed';

      expect(instruction.metadata['source'], 'test');
    });

    test('copyWith changes selected values', () {
      final original = createInstruction();

      final updated = original.copyWith(
        operationId: 'operation_002',
        consultationId: 'consultation_002',
        metadata: const <String, Object?>{'source': 'copy'},
      );

      expect(updated.operationId, 'operation_002');
      expect(updated.consultationId, 'consultation_002');
      expect(updated.metadata['source'], 'copy');

      expect(updated.settlementId, original.settlementId);
      expect(updated.lines, original.lines);
      expect(updated.escrowId, original.escrowId);
      expect(updated.clientId, original.clientId);
      expect(updated.expertId, original.expertId);
      expect(updated.occurredAt, original.occurredAt);
    });

    test('copyWith preserves omitted values', () {
      final original = createInstruction();
      final copy = original.copyWith();

      expect(copy, original);
      expect(copy.hashCode, original.hashCode);
    });

    test('identical instructions are equal', () {
      final first = createInstruction();
      final second = createInstruction();

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('different instructions are not equal', () {
      final first = createInstruction();

      final second = first.copyWith(operationId: 'operation_002');

      expect(first, isNot(second));
    });

    test('rejects an empty lines collection', () {
      expect(
        () => createInstruction(lines: const <SettlementPostingLine>[]),
        throwsA(
          isA<ArgumentError>().having((error) => error.name, 'name', 'lines'),
        ),
      );
    });

    test('rejects lines using different currencies', () {
      expect(
        () => createInstruction(
          lines: <SettlementPostingLine>[
            createLine(minorUnits: 8500, currency: FinancialCurrency.xof),
            createLine(
              party: SettlementParty.platform,
              category: SettlementPostingCategory.platformRevenue,
              minorUnits: 1500,
              currency: FinancialCurrency.usd,
              code: 'PLATFORM_REVENUE',
              label: 'Platform revenue',
            ),
          ],
        ),
        throwsA(
          isA<ArgumentError>().having((error) => error.name, 'name', 'lines'),
        ),
      );
    });

    test('instructions with different line categories are not equal', () {
      final first = createInstruction();

      final second = createInstruction(
        lines: <SettlementPostingLine>[
          createLine(category: SettlementPostingCategory.platformRevenue),
          createLine(
            party: SettlementParty.platform,
            category: SettlementPostingCategory.platformRevenue,
            minorUnits: 1500,
            code: 'PLATFORM_REVENUE',
            label: 'Platform revenue',
          ),
        ],
      );

      expect(first, isNot(second));
    });

    test('rejects an empty operationId', () {
      expect(
        () => SettlementPostingInstruction(
          settlementId: SettlementId('settlement_001'),
          operationId: '',
          consultationId: 'consultation_001',
          escrowId: 'escrow_001',
          clientId: 'client_001',
          expertId: 'expert_001',
          lines: <SettlementPostingLine>[createLine(minorUnits: 10000)],
          occurredAt: occurredAt,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.name,
            'name',
            'operationId',
          ),
        ),
      );
    });

    test('rejects whitespace-only identifiers', () {
      expect(
        () => SettlementPostingInstruction(
          settlementId: SettlementId('settlement_001'),
          operationId: 'operation_001',
          consultationId: '   ',
          escrowId: 'escrow_001',
          clientId: 'client_001',
          expertId: 'expert_001',
          lines: <SettlementPostingLine>[createLine(minorUnits: 10000)],
          occurredAt: occurredAt,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('toString contains useful information', () {
      final instruction = createInstruction();

      final value = instruction.toString();

      expect(value, contains('SettlementPostingInstruction'));
      expect(value, contains('settlement_001'));
      expect(value, contains('operation_001'));
      expect(value, contains('consultation_001'));
      expect(value, contains('XOF'));
      expect(value, contains('10000'));
    });
  });
}
