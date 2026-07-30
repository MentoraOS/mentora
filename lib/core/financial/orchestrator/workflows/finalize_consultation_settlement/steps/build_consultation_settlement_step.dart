import '../../../../domain/primitives/percentage/percentage.dart';
import '../../../../domain/settlement/settlements.dart';
import '../../../../domain/shared/money/financial_currency.dart';
import '../../../../domain/shared/money/money.dart';
import '../../../../domain/shared/rates/rates.dart';
import '../../../../pipeline/pipeline.dart';
import '../../../../splits/models/settlement_split.dart';
import '../../../../splits/models/settlement_split_component.dart';
import '../../../../splits/models/split_destination.dart';

import '../pipeline/finalize_consultation_settlement_context.dart';

/// Builds or restores the consultation settlement aggregate.
///
/// A new aggregate is created only for a brand-new settlement operation.
/// Resume and retry executions reuse the persisted aggregate after checking
/// that its financial lines still match the recalculated settlement split.
final class BuildConsultationSettlementStep
    implements FinancialPipelineStep<FinalizeConsultationSettlementContext> {
  const BuildConsultationSettlementStep();

  @override
  String get id => 'build-consultation-settlement';

  @override
  Future<void> execute(FinalizeConsultationSettlementContext context) async {
    final split = _requireValidSplit(context);

    final candidateSettlement = _buildCandidateSettlement(
      context: context,
      split: split,
    );

    final decision = context.requiredIdempotencyDecision;

    switch (decision) {
      case SettlementIdempotencyDecision.continueProcessing:
        if (context.existingSettlement != null) {
          throw StateError(
            'Cannot create a new settlement because a persisted '
            'settlement already exists for '
            '"${context.settlementId}".',
          );
        }

        SettlementValidator.validate(candidateSettlement);

        context.settlement = candidateSettlement;
        return;

      case SettlementIdempotencyDecision.resume:
      case SettlementIdempotencyDecision.retry:
        final existingSettlement = _requireExistingSettlement(context);

        SettlementValidator.validate(existingSettlement);

        _ensureFinanciallyEquivalent(
          existingSettlement: existingSettlement,
          candidateSettlement: candidateSettlement,
        );

        // Preserve the persisted lifecycle status, version and domain state.
        context.settlement = existingSettlement;
        return;

      case SettlementIdempotencyDecision.alreadyCompleted:
      case SettlementIdempotencyDecision.reject:
        throw StateError(
          'Settlement idempotency decision "$decision" '
          'should have stopped the pipeline before '
          'building the settlement aggregate.',
        );
    }
  }

  static SettlementSplit _requireValidSplit(
    FinalizeConsultationSettlementContext context,
  ) {
    final split = context.split;

    if (split == null) {
      throw StateError(
        'Cannot build the consultation settlement before '
        'the settlement split has been calculated.',
      );
    }

    if (!split.isBalanced) {
      throw StateError(
        'Cannot build a consultation settlement from '
        'an unbalanced settlement split.',
      );
    }

    if (split.grossAmountMinor <= 0) {
      throw StateError(
        'Cannot build a consultation settlement from '
        'a non-positive gross amount.',
      );
    }

    return split;
  }

  static ConsultationSettlement _buildCandidateSettlement({
    required FinalizeConsultationSettlementContext context,
    required SettlementSplit split,
  }) {
    final currency = FinancialCurrency.fromCode(split.currency);

    final lines = split.components
        .map(
          (component) => SettlementLine(
            party: _mapParty(component.destination),
            rate: _buildRate(
              component: component,
              grossAmountMinor: split.grossAmountMinor,
            ),
            amount: Money(
              minorUnits: component.amountMinor,
              currency: currency,
            ),
          ),
        )
        .toList(growable: false);

    return ConsultationSettlement(id: context.settlementId, lines: lines);
  }

  static ConsultationSettlement _requireExistingSettlement(
    FinalizeConsultationSettlementContext context,
  ) {
    final existingSettlement = context.existingSettlement;

    if (existingSettlement == null) {
      throw StateError(
        'Settlement decision '
        '"${context.requiredIdempotencyDecision}" '
        'requires an existing persisted settlement.',
      );
    }

    if (existingSettlement.id != context.settlementId) {
      throw StateError(
        'Loaded settlement identifier does not match '
        'the current operation: '
        'expected=${context.settlementId}, '
        'actual=${existingSettlement.id}.',
      );
    }

    return existingSettlement;
  }

  static void _ensureFinanciallyEquivalent({
    required ConsultationSettlement existingSettlement,
    required ConsultationSettlement candidateSettlement,
  }) {
    final existingLines = existingSettlement.lines;
    final candidateLines = candidateSettlement.lines;

    if (existingLines.length != candidateLines.length) {
      throw StateError(
        'Persisted settlement cannot be resumed because '
        'its number of financial lines changed: '
        'persisted=${existingLines.length}, '
        'recalculated=${candidateLines.length}.',
      );
    }

    for (var index = 0; index < existingLines.length; index++) {
      final existingLine = existingLines[index];
      final candidateLine = candidateLines[index];

      if (existingLine != candidateLine) {
        throw StateError(
          'Persisted settlement cannot be resumed because '
          'financial line $index changed: '
          'persisted=$existingLine, '
          'recalculated=$candidateLine.',
        );
      }
    }
  }

  static SettlementParty _mapParty(SplitDestination destination) {
    return switch (destination) {
      SplitDestination.expertWallet => SettlementParty.expert,

      SplitDestination.platformRevenue => SettlementParty.platform,

      SplitDestination.taxPayable => SettlementParty.tax,

      SplitDestination.paymentProviderFee => SettlementParty.paymentProvider,
    };
  }

  static FinancialRate _buildRate({
    required SettlementSplitComponent component,
    required int grossAmountMinor,
  }) {
    final partsPerMillion = _calculatePartsPerMillion(
      amountMinor: component.amountMinor,
      grossAmountMinor: grossAmountMinor,
    );

    final percentage = Percentage.fromPartsPerMillion(partsPerMillion);

    return switch (component.destination) {
      SplitDestination.expertWallet => RevenueShare(percentage),

      SplitDestination.platformRevenue => FeeRate(percentage),

      SplitDestination.taxPayable => VatRate(percentage),

      SplitDestination.paymentProviderFee => FeeRate(percentage),
    };
  }

  /// Calculates the allocation rate using integer half-up rounding.
  ///
  /// This avoids floating-point arithmetic inside the financial domain.
  static int _calculatePartsPerMillion({
    required int amountMinor,
    required int grossAmountMinor,
  }) {
    final numerator =
        amountMinor * Percentage.partsPerMillionInOneHundredPercent;

    return (numerator + (grossAmountMinor ~/ 2)) ~/ grossAmountMinor;
  }
}
