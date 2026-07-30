import 'package:flutter/material.dart';
import '../core/engines/identity/widgets/admin_guard.dart';
import '../theme/mentora_theme.dart';
import '../core/routing/app_router.dart';
import 'withdrawal_admin_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        backgroundColor: MentoraColors.navy,
        appBar: AppBar(
          backgroundColor: MentoraColors.navy,
          elevation: 0,
          title: const Text('Admin Dashboard'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _AdminHero(),

              const SizedBox(height: 20),

              _AdminMenuCard(
                icon: Icons.payments,
                title: 'Demandes de retrait',
                subtitle: 'Approuver ou rejeter les retraits experts',
                onTap: () {
                  AppRouter.openWithdrawalAdmin(context);
                },
              ),

              _AdminMenuCard(
                icon: Icons.people,
                title: 'Utilisateurs',
                subtitle: 'Gérer les comptes clients et experts',
                onTap: () {},
              ),

              _AdminMenuCard(
                icon: Icons.school,
                title: 'Experts',
                subtitle: 'Validation, suspension et vérification',
                onTap: () {},
              ),

              _AdminMenuCard(
                icon: Icons.account_balance_wallet,
                title: 'Finance',
                subtitle: 'Ledger, escrow, revenus et paiements',
                onTap: () {},
              ),

              _AdminMenuCard(
                icon: Icons.calendar_month,
                title: 'Réservations',
                subtitle: 'Suivre les consultations et statuts',
                onTap: () {},
              ),

              _AdminMenuCard(
                icon: Icons.gavel,
                title: 'Litiges',
                subtitle: 'Traiter les remboursements et conflits',
                onTap: () {},
              ),

              _AdminMenuCard(
                icon: Icons.public,
                title: 'Pays',
                subtitle: 'Règles locales, devises et moyens de paiement',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: MentoraColors.gold.withOpacity(.35)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.admin_panel_settings, color: MentoraColors.gold, size: 46),
          SizedBox(height: 14),
          Text(
            'Centre de Commandement Mentora',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Gérez les opérations critiques de la plateforme : finance, experts, utilisateurs, pays et conformité.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminMenuCard({
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
