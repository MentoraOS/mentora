import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/mentora_theme.dart';
import '../theme/theme_provider.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<MentoraThemeProvider>();
    final currentMode = themeProvider.themeMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Apparence')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Choisissez votre thème',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Personnalisez l’apparence de Mentora selon votre préférence.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          _ThemeOptionCard(
            icon: Icons.light_mode,
            title: 'Mode clair',
            subtitle: 'Interface lumineuse et minimaliste.',
            selected: currentMode == ThemeMode.light,
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.light);
            },
          ),

          const SizedBox(height: 14),

          _ThemeOptionCard(
            icon: Icons.dark_mode,
            title: 'Mode sombre',
            subtitle: 'Fond bleu marine premium Mentora.',
            selected: currentMode == ThemeMode.dark,
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.dark);
            },
          ),

          const SizedBox(height: 14),

          _ThemeOptionCard(
            icon: Icons.phone_android,
            title: 'Système',
            subtitle: 'Suit automatiquement le thème du téléphone.',
            selected: currentMode == ThemeMode.system,
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.system);
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(MentoraRadius.large),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(MentoraRadius.large),
          border: Border.all(
            color: selected ? MentoraColors.gold : Colors.transparent,
            width: 1.6,
          ),
          boxShadow: MentoraShadows.soft,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: MentoraColors.gold.withOpacity(0.16),
              child: Icon(icon, color: MentoraColors.gold),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? MentoraColors.gold : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
