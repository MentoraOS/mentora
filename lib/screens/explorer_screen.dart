import 'package:flutter/material.dart';
import 'expert_profile_screen.dart';
import '../core/routing/app_router.dart';

class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});

  static const navy = Color(0xFF061A3D);
  static const gold = Color(0xFFF5A400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.4,
              colors: [Color(0xFF173A70), Color(0xFF061A3D), Color(0xFF020B1F)],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 24),
                const Text(
                  'Trouvez votre expert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                _searchBar(),
                const SizedBox(height: 18),
                _filters(),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.62,
                  children: const [
                    _ExpertGridCard(
                      image: 'assets/images/experts/mamadou_k.png',
                      name: 'Mamadou K.',
                      job: 'CEO & Growth Advisor',
                      country: '🇫🇷',
                      price: '50 000 FCFA',
                      rating: '4,9',
                      badge: '⭐ Top',
                    ),

                    _ExpertGridCard(
                      image: 'assets/images/experts/awa_diop.png',
                      name: 'Awa Diop',
                      job: 'Marketing Expert',
                      country: '🇸🇳',
                      price: '45 000 FCFA',
                      rating: '4,8',
                      badge: '🔥 Demandé',
                    ),

                    _ExpertGridCard(
                      image: 'assets/images/experts/koffi_amani.png',
                      name: 'Koffi Amani',
                      job: 'Expert Finance',
                      country: '🇨🇮',
                      price: '60 000 FCFA',
                      rating: '4,9',
                      badge: '⭐ Top',
                    ),

                    _ExpertGridCard(
                      image: 'assets/images/experts/njeri_w.png',
                      name: 'Njeri W.',
                      job: 'Business Coach',
                      country: '🇰🇪',
                      price: '40 000 FCFA',
                      rating: '4,7',
                      badge: '🔥 Demandé',
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _becomeExpertCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Image.asset('assets/images/logo_mentora.png', width: 46),
        const SizedBox(width: 10),
        const Text(
          'MENTORA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        const Icon(Icons.notifications_none, color: Colors.white, size: 26),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 19,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, color: navy),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const TextField(
        style: TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher un expert, compétence...',
          hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 19),
        ),
      ),
    );
  }

  Widget _filters() {
    final filters = ['Domaine', 'Compétence', 'Pays', 'Trier'];

    return Row(
      children: filters.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 15,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _becomeExpertCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: navy,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.groups_rounded, color: gold, size: 30),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vous êtes expert ?',
                  style: TextStyle(
                    color: navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Développez votre visibilité sur Mentora.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  final String image;
  final String name;
  final String job;
  final String country;
  final String price;
  final String rating;
  final List<String> tags;
  final String badge;

  const _ExpertCard({
    required this.image,
    required this.name,
    required this.job,
    required this.country,
    required this.price,
    required this.rating,
    required this.tags,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061A3D);
    const gold = Color(0xFFF5A400);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: Image.asset(
                  image,
                  height: 185,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: navy,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Text(country, style: const TextStyle(fontSize: 24)),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: navy,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: Colors.blue, size: 17),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  job,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: gold, size: 17),
                    Text(
                      ' $rating',
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const Text(
                      ' (128 avis)',
                      style: TextStyle(color: Colors.black45, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$price /h',
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: navy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Voir le profil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpertGridCard extends StatelessWidget {
  final String image;
  final String name;
  final String job;
  final String country;
  final String price;
  final String rating;
  final String badge;

  const _ExpertGridCard({
    required this.image,
    required this.name,
    required this.job,
    required this.country,
    required this.price,
    required this.rating,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061A3D);
    const gold = Color(0xFFF5A400);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Image.asset(
                  image,
                  height: 105,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 7,
                left: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: navy,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                left: 7,
                child: Text(country, style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  job,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star, color: gold, size: 14),
                    Text(
                      ' $rating',
                      style: const TextStyle(
                        color: navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$price /h',
                        style: const TextStyle(
                          color: navy,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        AppRouter.openExpertProfile(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: navy,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Text(
                          'Profil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
