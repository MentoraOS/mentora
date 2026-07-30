import 'package:flutter/material.dart';

class TodaySessionsCard extends StatelessWidget {
  const TodaySessionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes sessions aujourd’hui',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          _SessionItem(
            time: '09h00',
            title: 'Finance stratégique',
            status: 'À venir',
          ),
          SizedBox(height: 12),

          _SessionItem(
            time: '14h00',
            title: 'Leadership professionnel',
            status: 'Prochaine',
          ),
          SizedBox(height: 12),

          _SessionItem(
            time: '16h30',
            title: 'Négociation en entreprise',
            status: 'Planifiée',
          ),
        ],
      ),
    );
  }
}

class _SessionItem extends StatelessWidget {
  final String time;
  final String title;
  final String status;

  const _SessionItem({
    required this.time,
    required this.title,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle, color: Colors.orangeAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$time · $title',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
