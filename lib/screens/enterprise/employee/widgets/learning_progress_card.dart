import 'package:flutter/material.dart';

class LearningProgressCard extends StatelessWidget {
  const LearningProgressCard({super.key});

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
            'Ma progression',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16),

          LinearProgressIndicator(
            value: 0.68,
            minHeight: 8,
            backgroundColor: Colors.white24,
            color: Colors.orangeAccent,
          ),

          SizedBox(height: 12),

          Text(
            '68% de progression ce mois-ci',
            style: TextStyle(color: Colors.white70),
          ),

          SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ProgressItem(
                value: '12h',
                label: 'Apprentissage',
                icon: Icons.timer,
              ),
              _ProgressItem(
                value: '4',
                label: 'Certificats',
                icon: Icons.workspace_premium,
              ),
              _ProgressItem(
                value: '8',
                label: 'Compétences',
                icon: Icons.psychology,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _ProgressItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.orangeAccent),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
