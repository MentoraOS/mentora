import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/expert_catalog/expert_catalog_application_service.dart';
import '../domain/expert_catalog/expert_catalog_entry.dart';
import '../theme/mentora_theme.dart';
import 'profile_screen.dart';
import '../core/routing/app_router.dart';

const navy = Color(0xFF061A3D);
const gold = Color(0xFFFFA400);

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _HomeDashboard(),
      const _ExplorerScreen(),
      const _PlaceholderPage(title: 'Sessions'),
      const _PlaceholderPage(title: 'Masterclass'),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: gold,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorer'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle),
            label: 'Masterclass',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  _HomeDashboard();

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.business_center, "title": "Business"},
    {"icon": Icons.computer, "title": "Tech"},
    {"icon": Icons.trending_up, "title": "Marketing"},
    {"icon": Icons.account_balance, "title": "Finance"},
    {"icon": Icons.gavel, "title": "Droit"},
    {"icon": Icons.auto_awesome, "title": "IA"},
    {"icon": Icons.health_and_safety, "title": "Santé"},
    {"icon": Icons.grid_view_rounded, "title": "Voir tout"},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            Text(
              'Bonsoir Hassey 👋',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 8),

            Text(
              'Prêt à apprendre quelque chose aujourd’hui ?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 22),

            TextField(
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher un expert, une compétence...',
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                prefixIcon: const Icon(Icons.search, color: MentoraColors.gold),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MentoraRadius.pill),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: MentoraShadows.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: MentoraColors.gold,
                        child: Icon(
                          Icons.person,
                          color: MentoraColors.navy,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prochaine consultation',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Moussa Keita',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.verified,
                        color: MentoraColors.gold,
                        size: 22,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Expert Marketing • Sénégal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: MentoraColors.gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: MentoraColors.gold,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Aujourd’hui • 16:30 - 17:00',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Colors.greenAccent,
                        size: 9,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Démarre bientôt',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Dans 18 min',
                        style: TextStyle(
                          color: MentoraColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.video_call),
                      label: const Text('Rejoindre la vidéo'),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Center(
                    child: Text(
                      'Voir les détails →',
                      style: TextStyle(
                        color: MentoraColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text('Catégories', style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 14,
                mainAxisSpacing: 18,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final item = categories[index];

                return _CategoryCard(
                  icon: item["icon"] as IconData,
                  title: item["title"] as String,
                );
              },
            ),

            const SizedBox(height: 24),

            Text(
              'Experts populaires',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            const _ExpertsGrid(),
          ],
        ),
      ),
    );
  }
}

class _ExplorerScreen extends StatelessWidget {
  const _ExplorerScreen();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mentora',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleMedium?.color,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Text(
              'Trouvez votre expert',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleMedium?.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16),

            _SearchBox(),

            SizedBox(height: 18),

            _FilterRow(),

            SizedBox(height: 18),

            _ExpertsGrid(),
          ],
        ),
      ),
    );
  }
}

class _ExpertsGrid extends StatelessWidget {
  const _ExpertsGrid();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ExpertCatalogEntry>>(
      stream: context.read<ExpertCatalogApplicationService>().watchExperts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: gold));
        }

        final experts = snapshot.data!;

        if (experts.isEmpty) {
          return Text(
            'Aucun expert disponible.',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: experts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.52,
          ),
          itemBuilder: (context, index) {
            final expert = experts[index];

            return GestureDetector(
              onTap: () {
                AppRouter.openExpertDetails(context: context, expert: expert);
              },
              child: _ExpertCard(expert: expert),
            );
          },
        );
      },
    );
  }
}

class _ExpertCard extends StatelessWidget {
  final ExpertCatalogEntry expert;

  const _ExpertCard({required this.expert});

  @override
  Widget build(BuildContext context) {
    final consultations = expert.consultations ?? '120';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: MentoraShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 34,
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFF1F3F8)
                  : Colors.white,
              child: const Icon(
                Icons.person,
                color: MentoraColors.gold,
                size: 32,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            expert.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 4),

          const SizedBox(height: 8),

          Text(
            '${expert.job} • ${expert.country}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 12, height: 1.25),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: MentoraColors.gold.withOpacity(0.14),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: MentoraColors.gold, size: 13),
                SizedBox(width: 5),
                Text(
                  'Mentora Verified',
                  style: TextStyle(
                    color: MentoraColors.gold,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.star, color: MentoraColors.gold, size: 15),
              const SizedBox(width: 4),
              Text(
                expert.rating,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$consultations consultations',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 10),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text(
                'Voir le profil',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CategoryCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: MentoraShadows.soft,
            ),
            child: Icon(icon, color: MentoraColors.gold, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: MentoraColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Text(
            'Rechercher un expert, compétence...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _FilterChipText('Domaine'),
        SizedBox(width: 8),
        _FilterChipText('Compétence'),
        SizedBox(width: 8),
        _FilterChipText('Pays'),
        SizedBox(width: 8),
        _FilterChipText('Trier'),
      ],
    );
  }
}

class _FilterChipText extends StatelessWidget {
  final String text;

  const _FilterChipText(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).textTheme.titleMedium?.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleMedium?.color,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
