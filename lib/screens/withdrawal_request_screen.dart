import 'package:flutter/material.dart';
import '../core/engines/financial/withdrawals/withdrawal_engine.dart';
import '../theme/mentora_theme.dart';
import '../core/engines/financial/wallet/wallet_engine.dart';

class WithdrawalRequestScreen extends StatefulWidget {
  final String expertId;
  final String currency;
  final String countryCode;

  const WithdrawalRequestScreen({
    super.key,
    required this.expertId,
    required this.currency,
    required this.countryCode,
  });

  @override
  State<WithdrawalRequestScreen> createState() =>
      _WithdrawalRequestScreenState();
}

class _WithdrawalRequestScreenState extends State<WithdrawalRequestScreen> {
  final amountController = TextEditingController();
  final destinationController = TextEditingController();

  String method = 'mobile_money';
  bool loading = false;

  @override
  void dispose() {
    amountController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  Future<void> submitWithdrawal() async {
    final amount = int.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Montant invalide')));
      return;
    }

    if (destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer votre numéro ou compte')),
      );
      return;
    }

    final wallet = await WalletEngine.expertBalance(
      expertId: widget.expertId,
      currency: widget.currency,
    );

    if (amount > wallet.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solde insuffisant pour ce retrait')),
      );
      return;
    }

    setState(() => loading = true);

    await WithdrawalEngine.firestore().createWithdrawalRequest(
      expertId: widget.expertId,
      amount: amount,
      currency: widget.currency,
      countryCode: widget.countryCode,
      method: method,
      destination: destinationController.text.trim(),
    );

    if (!mounted) return;

    setState(() => loading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Demande de retrait envoyée')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MentoraColors.navy,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        title: const Text('Demande de retrait'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Montant à retirer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ex : 25000',
                      suffixText: widget.currency,
                      hintStyle: const TextStyle(color: Colors.white38),
                      suffixStyle: const TextStyle(color: MentoraColors.gold),
                      filled: true,
                      fillColor: Colors.white.withOpacity(.07),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Méthode de retrait',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MethodTile(
                    selected: method == 'mobile_money',
                    title: 'Mobile Money',
                    subtitle: 'Orange Money, Wave, Moov, MTN',
                    icon: Icons.account_balance_wallet,
                    onTap: () => setState(() => method = 'mobile_money'),
                  ),
                  const SizedBox(height: 10),
                  _MethodTile(
                    selected: method == 'bank',
                    title: 'Compte bancaire',
                    subtitle: 'Retrait vers une banque',
                    icon: Icons.account_balance,
                    onTap: () => setState(() => method = 'bank'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method == 'mobile_money'
                        ? 'Numéro Mobile Money'
                        : 'Informations du compte bancaire',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: destinationController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: method == 'mobile_money'
                          ? 'Ex : +223 78 00 00 00'
                          : 'Nom banque / IBAN / numéro compte',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(.07),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: loading ? null : submitWithdrawal,
                icon: const Icon(Icons.payments),
                label: Text(
                  loading ? 'Envoi en cours...' : 'Envoyer la demande',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }
}

class _MethodTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MethodTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? MentoraColors.gold.withOpacity(.16)
              : Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? MentoraColors.gold : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: MentoraColors.gold),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(color: Colors.white60)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: MentoraColors.gold),
          ],
        ),
      ),
    );
  }
}
