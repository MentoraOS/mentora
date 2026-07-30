import 'package:flutter/material.dart';
import '../core/engines/financial/wallet/wallet_engine.dart';
import '../theme/mentora_theme.dart';

class ExpertWalletScreen extends StatelessWidget {
  final String expertId;
  final String currency;

  const ExpertWalletScreen({
    super.key,
    required this.expertId,
    required this.currency,
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
        title: const Text('Wallet Expert'),
      ),
      body: FutureBuilder(
        future: WalletEngine.expertBalance(
          expertId: expertId,
          currency: currency,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: MentoraColors.gold),
            );
          }

          final wallet = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: MentoraColors.gold,
                        size: 54,
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Solde disponible',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${formatMoney(wallet.balance)} ${wallet.currency}',
                        style: const TextStyle(
                          color: MentoraColors.gold,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
