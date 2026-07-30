import '../../../../domain/settlement/settlements.dart';

import '../models/settlement_posting_instruction.dart';
import '../models/settlement_posting_line.dart';
import '../models/settlement_posting_category.dart';

/// Builds a Ledger-ready posting instruction from a validated settlement.
///
/// This factory is the boundary between the Settlement Domain and the
/// technical accounting contract consumed by the posting workflow.
final class SettlementPostingInstructionFactory {
  const SettlementPostingInstructionFactory();

  SettlementPostingInstruction create({
    required ConsultationSettlement settlement,
    required String operationId,
    required String consultationId,
    required String escrowId,
    required String clientId,
    required String expertId,
    required DateTime occurredAt,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    SettlementValidator.validate(settlement);

    final lines = settlement.lines
        .map(_buildPostingLine)
        .toList(growable: false);

    return SettlementPostingInstruction(
      settlementId: settlement.id,
      operationId: operationId,
      consultationId: consultationId,
      escrowId: escrowId,
      clientId: clientId,
      expertId: expertId,
      lines: lines,
      occurredAt: occurredAt,
      metadata: <String, Object?>{
        ...metadata,
        'settlementId': settlement.id.value,
        'settlementStatus': settlement.status.name,
      },
    );
  }

  static SettlementPostingLine _buildPostingLine(SettlementLine line) {
    final accounting = _accountingFor(line.party);

    return SettlementPostingLine(
      party: line.party,
      amount: line.amount,
      code: accounting.code,
      label: accounting.label,
      category: accounting.category,
    );
  }

  static _SettlementAccountingMapping _accountingFor(SettlementParty party) {
    return switch (party) {
      SettlementParty.expert => const _SettlementAccountingMapping(
        category: SettlementPostingCategory.expertRevenue,
        code: 'EXPERT_REVENUE',
        label: 'Expert revenue',
      ),
      SettlementParty.platform => const _SettlementAccountingMapping(
        category: SettlementPostingCategory.platformRevenue,
        code: 'PLATFORM_REVENUE',
        label: 'Platform revenue',
      ),
      SettlementParty.tax => const _SettlementAccountingMapping(
        category: SettlementPostingCategory.taxPayable,
        code: 'TAX_PAYABLE',
        label: 'Tax payable',
      ),
      SettlementParty.paymentProvider => const _SettlementAccountingMapping(
        category: SettlementPostingCategory.paymentProviderFee,
        code: 'PAYMENT_PROVIDER_FEE',
        label: 'Payment provider fee',
      ),
      SettlementParty.affiliate => const _SettlementAccountingMapping(
        category: SettlementPostingCategory.affiliateCommission,
        code: 'AFFILIATE_COMMISSION',
        label: 'Affiliate commission',
      ),
      SettlementParty.partner => const _SettlementAccountingMapping(
        category: SettlementPostingCategory.partnerCommission,
        code: 'PARTNER_COMMISSION',
        label: 'Partner commission',
      ),
    };
  }
}

final class _SettlementAccountingMapping {
  const _SettlementAccountingMapping({
    required this.code,
    required this.label,
    required this.category,
  });

  final String code;
  final String label;
  final SettlementPostingCategory category;
}
