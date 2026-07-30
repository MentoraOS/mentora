import '../../../fees/engine/fee_engine.dart';
import '../financial_workflow.dart';
import 'settle_consultation_context.dart';
import 'settle_consultation_result.dart';

class SettleConsultationWorkflow
    implements
        FinancialWorkflow<SettleConsultationContext, SettleConsultationResult> {
  static const String workflowKey = 'settle.consultation';

  final FeeEngine feeEngine;

  const SettleConsultationWorkflow({required this.feeEngine});

  @override
  String get key => workflowKey;

  @override
  Future<SettleConsultationResult> execute(
    SettleConsultationContext context,
  ) async {
    _validateContext(context);

    final normalizedCurrency = context.currency.trim().toUpperCase();

    final feeQuote = feeEngine.calculate(
      policyKey: 'consultation',
      grossAmountMinor: context.grossAmountMinor,
      currency: normalizedCurrency,
    );

    if (!feeQuote.isBalanced) {
      throw StateError(
        'Consultation settlement generated an unbalanced fee quote',
      );
    }

    if (feeQuote.grossAmountMinor != context.grossAmountMinor) {
      throw StateError(
        'Consultation settlement changed the gross amount '
        'from ${context.grossAmountMinor} '
        'to ${feeQuote.grossAmountMinor}',
      );
    }

    if (feeQuote.breakdown.totalMinor != context.grossAmountMinor) {
      throw StateError(
        'Consultation settlement fee breakdown total '
        '${feeQuote.breakdown.totalMinor} does not equal '
        'gross amount ${context.grossAmountMinor}',
      );
    }

    return SettleConsultationResult(
      success: true,
      operationId: context.operationId.trim(),
      consultationId: context.consultationId.trim(),
      feeQuote: feeQuote,
      settledAt: context.occurredAt.toUtc(),
    );
  }

  void _validateContext(SettleConsultationContext context) {
    _requireNonEmpty(value: context.operationId, fieldName: 'operationId');

    _requireNonEmpty(
      value: context.consultationId,
      fieldName: 'consultationId',
    );

    _requireNonEmpty(value: context.paymentId, fieldName: 'paymentId');

    _requireNonEmpty(value: context.escrowId, fieldName: 'escrowId');

    _requireNonEmpty(value: context.clientId, fieldName: 'clientId');

    _requireNonEmpty(value: context.expertId, fieldName: 'expertId');

    _requireNonEmpty(value: context.currency, fieldName: 'currency');

    if (context.grossAmountMinor <= 0) {
      throw ArgumentError.value(
        context.grossAmountMinor,
        'grossAmountMinor',
        'Gross amount must be greater than zero',
      );
    }
  }

  void _requireNonEmpty({required String value, required String fieldName}) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, fieldName, '$fieldName cannot be empty');
    }
  }
}
