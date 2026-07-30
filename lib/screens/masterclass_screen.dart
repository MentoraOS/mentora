import 'package:flutter/material.dart';

class MasterclassScreen extends StatelessWidget {
  const MasterclassScreen({super.key});

  static const navy = Color(0xFF061A3D);
  static const gold = Color(0xFFF5A400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Masterclass',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Apprenez en groupe avec des experts premium.',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              SizedBox(height: 26),

              _FeaturedCourse(),

              SizedBox(height: 28),

              Text(
                'Cours recommandés',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 14),

              _CourseCard(
                title: 'Lever des fonds en Afrique',
                expert: 'Mamadou K.',
                price: '15 000 FCFA',
                icon: Icons.trending_up,
              ),

              SizedBox(height: 14),

              _CourseCard(
                title: 'Marketing digital pour PME',
                expert: 'Awa Diop',
                price: '12 000 FCFA',
                icon: Icons.campaign,
              ),

              SizedBox(height: 14),

              _CourseCard(
                title: 'Finance pour entrepreneurs',
                expert: 'Koffi Amani',
                price: '20 000 FCFA',
                icon: Icons.account_balance,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCourse extends StatelessWidget {
  const _FeaturedCourse();

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061A3D);
    const gold = Color(0xFFF5A400);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: gold,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.school, color: navy, size: 42),
          const SizedBox(height: 20),
          const Text(
            'Masterclass en direct',
            style: TextStyle(
              color: navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Construire une startup rentable en Afrique',
            style: TextStyle(
              color: navy,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Avec Mamadou K. • Samedi 29 Juin • 18h00',
            style: TextStyle(
              color: navy,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'S’inscrire maintenant',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final String title;
  final String expert;
  final String price;
  final IconData icon;

  const _CourseCard({
    required this.title,
    required this.expert,
    required this.price,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061A3D);
    const gold = Color(0xFFF5A400);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: navy,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: gold, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  expert,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              color: navy,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
