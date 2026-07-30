import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/workspace/workspace_state.dart';
import '../core/routing/app_router.dart';
import '../theme/mentora_theme.dart';

class CompanyDashboardScreen extends StatelessWidget {
  const CompanyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workspace = context.read<WorkspaceState>().currentWorkspace;

    return Scaffold(
      backgroundColor: MentoraColors.navy,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        title: const Text('Espace Entreprise'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Icon(Icons.business, color: MentoraColors.gold, size: 56),
                const SizedBox(height: 16),
                Text(
                  workspace?.name ?? 'Entreprise',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  workspace?.role ?? 'member',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enterprise Console',
                  style: TextStyle(color: MentoraColors.gold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Administration',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          _EnterpriseTile(
            icon: Icons.group,
            title: 'Membres',
            subtitle: 'Gérer les collaborateurs',
            onTap: () => AppRouter.openEnterpriseMembers(context),
          ),

          _EnterpriseTile(
            icon: Icons.mail,
            title: 'Invitations',
            subtitle: 'Voir et gérer les invitations',
            onTap: () => AppRouter.openEnterpriseInvitations(context),
          ),

          _EnterpriseTile(
            icon: Icons.apartment,
            title: 'Départements',
            subtitle: 'Finance, RH, IT, Marketing',
            onTap: () {},
          ),

          _EnterpriseTile(
            icon: Icons.video_call,
            title: 'Mentora Live Business',
            subtitle: 'Lives réservés aux équipes',
            onTap: () {},
          ),

          _EnterpriseTile(
            icon: Icons.analytics,
            title: 'Analytics',
            subtitle: 'Présence, progression, ROI',
            onTap: () {},
          ),

          _EnterpriseTile(
            icon: Icons.receipt_long,
            title: 'Facturation',
            subtitle: 'Paiements et factures entreprise',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _EnterpriseTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _EnterpriseTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: MentoraColors.gold),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
      ),
    );
  }
}
