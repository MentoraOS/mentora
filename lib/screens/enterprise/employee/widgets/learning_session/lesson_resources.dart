import 'package:flutter/material.dart';

class LessonResources extends StatelessWidget {
  const LessonResources({super.key});

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
            'Ressources',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          _ResourceTile(
            icon: Icons.picture_as_pdf,
            color: Colors.redAccent,
            title: 'Support de cours',
            subtitle: 'Leadership_Professionnel.pdf',
          ),

          const SizedBox(height: 12),

          _ResourceTile(
            icon: Icons.slideshow,
            color: Colors.orangeAccent,
            title: 'Présentation',
            subtitle: 'Slides de la leçon',
          ),

          const SizedBox(height: 12),

          _ResourceTile(
            icon: Icons.description,
            color: Colors.lightBlueAccent,
            title: 'Exercice',
            subtitle: 'Cas pratique à télécharger',
          ),
        ],
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _ResourceTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: ouvrir ou télécharger la ressource
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const Icon(Icons.download_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
