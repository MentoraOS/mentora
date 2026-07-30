import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/favorites/favorite_experts_application_service.dart';
import '../application/favorites/favorite_experts_failure.dart';
import '../domain/favorites/favorite_expert.dart';
import '../theme/mentora_theme.dart';

class FavoriteExpertsScreen extends StatelessWidget {
  const FavoriteExpertsScreen({super.key});

  Future<void> _removeFavorite({
    required BuildContext context,
    required String expertId,
    required String expertName,
  }) async {
    try {
      await context
          .read<FavoriteExpertsApplicationService>()
          .removeCurrentFavorite(expertId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$expertName retiré des favoris')));
    } on FavoriteExpertsFailure {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de retirer ce favori')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    late final Stream<List<FavoriteExpert>> favorites;

    try {
      favorites = context
          .read<FavoriteExpertsApplicationService>()
          .observeCurrentFavorites();
    } on FavoriteExpertsUnauthenticatedFailure {
      return const Scaffold(body: Center(child: Text('Session introuvable')));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Experts favoris')),
      body: StreamBuilder<List<FavoriteExpert>>(
        stream: favorites,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Impossible de charger les experts favoris.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: MentoraColors.gold),
            );
          }

          final experts = snapshot.data!;

          if (experts.isEmpty) {
            return Center(
              child: Text(
                'Aucun expert favori pour le moment.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: experts.length,
            itemBuilder: (context, index) {
              final expert = experts[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(MentoraRadius.large),
                  boxShadow: MentoraShadows.soft,
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: MentoraColors.gold,
                      child: Icon(
                        Icons.person,
                        color: MentoraColors.navy,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expert.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${expert.title} • ${expert.country}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: MentoraColors.gold,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                expert.rating,
                                style: const TextStyle(
                                  color: MentoraColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                expert.price,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () => _removeFavorite(
                        context: context,
                        expertId: expert.id,
                        expertName: expert.name,
                      ),
                      icon: const Icon(Icons.favorite, color: Colors.redAccent),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
