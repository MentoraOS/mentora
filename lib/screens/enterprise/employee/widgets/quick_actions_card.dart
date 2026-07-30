import 'package:flutter/material.dart';

import '../../../../core/routing/app_router.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _QuickActionItem(
                  icon: Icons.video_call,
                  title: 'Session',
                  subtitle: 'Rejoindre',
                  onTap: () {
                    // TODO: Employee Live Session
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _QuickActionItem(
                  icon: Icons.support_agent,
                  title: 'RH',
                  subtitle: 'Contacter',
                  onTap: () {
                    // TODO: HR Support
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _QuickActionItem(
                  icon: Icons.menu_book,
                  title: 'Formations',
                  subtitle: 'Explorer',
                  onTap: () {
                    AppRouter.openEmployeeTrainingCatalog(context);
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _QuickActionItem(
                  icon: Icons.workspace_premium,
                  title: 'Certificats',
                  subtitle: 'Voir',
                  onTap: () {
                    // TODO: Employee Certificates
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _QuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.orangeAccent, size: 30),

            const SizedBox(height: 12),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
