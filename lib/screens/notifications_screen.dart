import 'package:flutter/material.dart';
import '../theme/mentora_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'icon': Icons.calendar_month,
        'title': 'Consultation confirmée',
        'message': 'Votre consultation avec Moussa Keita est confirmée.',
        'time': 'Aujourd’hui • 10:30',
      },
      {
        'icon': Icons.payment,
        'title': 'Paiement validé',
        'message': 'Votre paiement de 15 000 FCFA a été reçu.',
        'time': 'Aujourd’hui',
      },
      {
        'icon': Icons.auto_awesome,
        'title': 'Résumé IA prêt',
        'message': 'Mentora AI a préparé votre résumé pour l’expert.',
        'time': 'Hier',
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(MentoraRadius.large),
              boxShadow: MentoraShadows.soft,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: MentoraColors.gold.withOpacity(0.18),
                  child: Icon(
                    item['icon'] as IconData,
                    color: MentoraColors.gold,
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['message'] as String,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['time'] as String,
                        style: const TextStyle(
                          color: MentoraColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
