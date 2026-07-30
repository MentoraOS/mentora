import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/financial/ledger/chart/account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/chart_of_accounts.dart';
import 'package:mentora/core/financial/ledger/chart/default_accounts.dart';
import 'package:mentora/core/financial/ledger/models/ledger_account.dart';
import 'package:mentora/core/financial/ledger/models/ledger_account_type.dart';

void main() {
  group('ChartOfAccounts', () {
    late AccountRegistry registry;
    late ChartOfAccounts chart;

    setUp(() {
      registry = AccountRegistry();

      chart = ChartOfAccounts(registry: registry);
    });

    test('should initialize platform accounts for a currency', () {
      chart.initializeCurrency('usd');

      const expectedAccountIds = <String>{
        'platform_cash_USD',
        'platform_clearing_USD',
        'platform_revenue_USD',
        'commission_revenue_USD',
        'tax_payable_USD',
        'affiliate_payable_USD',
        'partner_payable_USD',
        'refund_reserve_USD',
        'fx_reserve_USD',
      };
      final actualAccountIds = registry.allAccounts
          .map((account) => account.id)
          .toSet();

      expect(expectedAccountIds, hasLength(9));
      expect(actualAccountIds, expectedAccountIds);
      expect(registry.length, expectedAccountIds.length);
      expect(chart.platformCash('USD').currency, 'USD');
      expect(chart.platformRevenue('USD').type, LedgerAccountType.revenue);
      expect(chart.affiliatePayable('USD').type, LedgerAccountType.liability);
      expect(chart.partnerPayable('USD').type, LedgerAccountType.liability);
      expect(chart.refundReserve('USD').type, LedgerAccountType.liability);
    });

    test('should initialize the same currency idempotently', () {
      chart.initializeCurrency('USD');
      final accountsAfterFirstInitialization = _accountDefinitions(registry);

      chart.initializeCurrency('USD');
      final accountsAfterSecondInitialization = _accountDefinitions(registry);

      expect(accountsAfterFirstInitialization, hasLength(9));
      expect(
        accountsAfterSecondInitialization,
        accountsAfterFirstInitialization,
      );
      expect(
        accountsAfterSecondInitialization.keys.toSet(),
        accountsAfterFirstInitialization.keys.toSet(),
      );
      expect(registry.length, accountsAfterFirstInitialization.length);
    });

    test('should create a client wallet per owner and currency', () {
      final wallet = chart.ensureClientWallet(
        clientId: 'client_001',
        currency: 'usd',
      );

      expect(wallet.id, 'client_wallet_client_001_USD');
      expect(wallet.ownerId, 'client_001');
      expect(wallet.currency, 'USD');
      expect(wallet.type, LedgerAccountType.liability);
    });

    test('should create an expert wallet as a liability', () {
      final wallet = chart.ensureExpertWallet(
        expertId: 'expert_001',
        currency: 'XOF',
      );

      expect(wallet.id, 'expert_wallet_expert_001_XOF');
      expect(wallet.ownerId, 'expert_001');
      expect(wallet.type, LedgerAccountType.liability);
    });

    test('should create an escrow account per consultation', () {
      final escrow = chart.ensureEscrow(
        consultationId: 'consultation_001',
        currency: 'USD',
      );

      expect(escrow.id, 'escrow_consultation_001_USD');
      expect(escrow.ownerId, 'consultation_001');
      expect(escrow.type, LedgerAccountType.liability);
    });

    test('should reject an account id registered with another definition', () {
      final original = DefaultAccounts.platformCash(currency: 'USD');

      registry.register(original);

      final conflicting = LedgerAccount(
        id: original.id,
        ownerId: 'another_owner',
        currency: original.currency,
        type: original.type,
        name: original.name,
      );

      expect(() => registry.register(conflicting), throwsStateError);
    });

    test('should fail when requesting an unknown account', () {
      expect(() => registry.getRequired('unknown_account'), throwsStateError);
    });
  });
}

Map<String, List<Object?>> _accountDefinitions(AccountRegistry registry) {
  return <String, List<Object?>>{
    for (final account in registry.allAccounts)
      account.id: <Object?>[
        account.ownerId,
        account.currency,
        account.type,
        account.name,
        account.active,
      ],
  };
}
