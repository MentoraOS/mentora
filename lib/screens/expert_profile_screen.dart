import 'package:flutter/material.dart';
import 'booking_screen.dart';
import '../core/routing/app_router.dart';

class ExpertProfileScreen extends StatelessWidget {
  const ExpertProfileScreen({super.key});

  static const navy = Color(0xFF061A3D);
  static const gold = Color(0xFFF5A400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const Spacer(),
                  const Icon(Icons.favorite_border, color: Colors.white),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.asset(
                  'assets/images/experts/mamadou_k.png',
                  height: 310,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Mamadou K.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(Icons.verified, color: Colors.blue, size: 24),
                ],
              ),

              const SizedBox(height: 6),

              const Text(
                'CEO & Growth Advisor',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: const [
                  Icon(Icons.star, color: gold, size: 20),
                  SizedBox(width: 5),
                  Text(
                    '4,9',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('(128 avis)', style: TextStyle(color: Colors.white60)),
                  Spacer(),
                  Text(
                    '50 000 FCFA /h',
                    style: TextStyle(color: gold, fontWeight: FontWeight.w900),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'À propos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Mamadou accompagne les entrepreneurs, startups et PME dans leur stratégie de croissance, leur positionnement commercial et leur levée de fonds.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15.5,
                  height: 1.55,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Expertises',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _SkillChip('Stratégie'),
                  _SkillChip('Croissance'),
                  _SkillChip('Levée de fonds'),
                  _SkillChip('Business Model'),
                ],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
        child: SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              AppRouter.openBooking(
                context: context,
                expertName: 'Mamadou K.',
                expertRate: 50000,
                expertId: '1234567890',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Réserver une consultation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String text;

  const _SkillChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
