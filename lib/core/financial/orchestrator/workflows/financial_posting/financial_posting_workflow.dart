import '../financial_workflow.dart';
import 'financial_posting_context.dart';
import 'financial_posting_result.dart';
import 'models/settlement_posting_instruction.dart';
import 'settlement_posting_port.dart';

class FinancialPostingWorkflow
    implements
        FinancialWorkflow<FinancialPostingContext, FinancialPostingResult> {
  static const String workflowKey = 'post.financial.settlement';

  final SettlementPostingPort postingPort;

  const FinancialPostingWorkflow({required this.postingPort});

  @override
  String get key => workflowKey;

  @override
  Future<FinancialPostingResult> execute(
    FinancialPostingContext context,
  ) async {
    _validateContext(context);

    final instruction = context.instruction;

    final receipt = await postingPort.postSettlement(instruction: instruction);

    if (!receipt.isComplete) {
      throw StateError(
        'Settlement posting port returned no ledger transaction',
      );
    }

    return FinancialPostingResult(
      success: true,
      operationId: instruction.operationId,
      consultationId: instruction.consultationId,
      ledgerTransactionIds: List<String>.unmodifiable(
        receipt.ledgerTransactionIds,
      ),
      postedAt: instruction.occurredAt.toUtc(),
    );
  }

  void _validateContext(FinancialPostingContext context) {
    _requireNonEmpty(value: context.operationId, fieldName: 'operationId');

    _requireNonEmpty(
      value: context.consultationId,
      fieldName: 'consultationId',
    );

    _requireNonEmpty(value: context.escrowId, fieldName: 'escrowId');

    _requireNonEmpty(value: context.clientId, fieldName: 'clientId');

    _requireNonEmpty(value: context.expertId, fieldName: 'expertId');

    _validateInstruction(context.instruction, context);
  }

  void _validateInstruction(
    SettlementPostingInstruction instruction,
    FinancialPostingContext context,
  ) {
    _requireNonEmpty(
      value: instruction.operationId,
      fieldName: 'instruction.operationId',
    );

    _requireNonEmpty(
      value: instruction.consultationId,
      fieldName: 'instruction.consultationId',
    );

    if (instruction.operationId.trim() != context.operationId.trim()) {
      throw StateError(
        'Settlement posting instruction operationId '
        'does not match the posting context: '
        'instruction=${instruction.operationId}, '
        'context=${context.operationId}',
      );
    }

    if (instruction.consultationId.trim() != context.consultationId.trim()) {
      throw StateError(
        'Settlement posting instruction consultationId '
        'does not match the posting context: '
        'instruction=${instruction.consultationId}, '
        'context=${context.consultationId}',
      );
    }

    if (instruction.lines.isEmpty) {
      throw StateError(
        'Settlement posting instruction must contain '
        'at least one line',
      );
    }

    if (instruction.totalMinorUnits <= 0) {
      throw ArgumentError.value(
        instruction.totalMinorUnits,
        'instruction.totalMinorUnits',
        'Posting total must be greater than zero',
      );
    }

    for (final line in instruction.lines) {
      if (line.amount.minorUnits < 0) {
        throw StateError(
          'Settlement posting instruction contains '
          'a negative line amount',
        );
      }

      _requireNonEmpty(value: line.code, fieldName: 'instruction.line.code');

      _requireNonEmpty(value: line.label, fieldName: 'instruction.line.label');
    }
  }

  void _requireNonEmpty({required String value, required String fieldName}) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, fieldName, '$fieldName cannot be empty');
    }
  }
}
