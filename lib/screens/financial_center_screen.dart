import 'package:flutter/material.dart';
import '../core/engines/financial/wallet/wallet_engine.dart';
import '../theme/mentora_theme.dart';
import '../core/routing/app_router.dart';

class FinancialCenterScreen extends StatelessWidget {
  final String expertId;
  final String currency;
  final String countryCode;

  const FinancialCenterScreen({
    super.key,
    required this.expertId,
    required this.currency,
    required this.countryCode,
  });

  String formatMoney(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MentoraColors.navy,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        title: const Text('Centre financier'),
      ),
      body: FutureBuilder(
        future: WalletEngine.expertBalance(
          expertId: expertId,
          currency: currency,
        ),
        builder: (context, snapshot) {
          final balanceText = snapshot.hasData
              ? '${formatMoney(snapshot.data!.balance)} ${snapshot.data!.currency}'
              : 'Chargement...';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _BalanceHero(balanceText: balanceText),

                const SizedBox(height: 20),

                _FinancialMenuCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Wallet',
                  subtitle: 'Voir votre solde disponible',
                  onTap: () {
                    AppRouter.openExpertWallet(
                      context: context,
                      expertId: expertId,
                      currency: currency,
                    );
                  },
                ),

                _FinancialMenuCard(
                  icon: Icons.trending_up,
                  title: 'Revenus',
                  subtitle: 'Suivre vos gains et performances',
                  onTap: () {},
                ),

                _FinancialMenuCard(
                  icon: Icons.lock,
                  title: 'Escrow',
                  subtitle: 'Montants en attente de libération',
                  onTap: () {
                    AppRouter.openExpertEscrowList(
                      context: context,
                      expertId: expertId,
                      currency: currency,
                    );
                  },
                ),

                _FinancialMenuCard(
                  icon: Icons.payments,
                  title: 'Retraits',
                  subtitle: 'Demander un retrait Mobile Money ou banque',
                  onTap: () {
                    AppRouter.openWithdrawalRequest(
                      context: context,
                      expertId: expertId,
                      currency: currency,
                      countryCode: countryCode,
                    );
                  },
                ),

                _FinancialMenuCard(
                  icon: Icons.receipt_long,
                  title: 'Historique',
                  subtitle: 'Transactions, commissions et paiements',
                  onTap: () {
                    AppRouter.openFinancialHistory(
                      context: context,
                      accountId: 'expert_wallet_$expertId',
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BalanceHero extends StatelessWidget {
  final String balanceText;

  const _BalanceHero({required this.balanceText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: MentoraColors.gold,
            size: 58,
          ),
          const SizedBox(height: 16),
          const Text('Solde expert', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            balanceText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: MentoraColors.gold,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FinancialMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.08),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: MentoraColors.gold.withOpacity(.16),
                child: Icon(icon, color: MentoraColors.gold),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white38,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
