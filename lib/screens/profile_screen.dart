import 'package:flutter/material.dart';
import 'my_bookings_screen.dart';
import '../application/profile/profile_application_service.dart';
import '../application/profile/profile_failure.dart';
import '../domain/profile/profile.dart';
import '../theme/mentora_theme.dart';
import 'edit_profile_screen.dart';
import 'expert_dashboard_screen.dart';
import 'my_payments_screen.dart';
import 'favorite_experts_screen.dart';
import 'notifications_screen.dart';
import 'package:provider/provider.dart';
import '../application/authentication/authentication_session.dart';
import '../theme/theme_provider.dart';
import 'appearance_screen.dart';
import 'admin_dashboard_screen.dart';
import '../core/routing/app_router.dart';
import '../core/workspace/widgets/workspace_switcher.dart';
import '../core/routing/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<AuthenticationSession>();
    final userId = session.currentUserId;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Session introuvable')));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
          child: StreamBuilder<Profile>(
            stream: context
                .read<ProfileApplicationService>()
                .observeCurrentProfile(),
            builder: (context, snapshot) {
              if (snapshot.hasError &&
                  snapshot.error is! ProfileNotFoundFailure) {
                return const Center(
                  child: Text('Impossible de charger le profil'),
                );
              }

              final profile = snapshot.data;
              final firstName = profile?.firstName ?? 'Hassey';
              final lastName = profile?.lastName ?? 'Diallo';
              final email = profile?.email ?? session.currentEmail ?? '';

              return Column(
                children: [
                  _ProfileHeader(
                    fullName: '$firstName $lastName',
                    email: email,
                  ),

                  const SizedBox(height: 18),

                  const _StatsCard(),

                  WorkspaceSwitcher(),

                  const SizedBox(height: 12),

                  ListTile(
                    leading: const Icon(Icons.business),
                    title: const Text('Espace Entreprise'),
                    subtitle: const Text('Accéder au dashboard entreprise'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      AppRouter.openCompanyDashboard(context);
                    },
                  ),

                  const SizedBox(height: 16),

                  const SizedBox(height: 22),

                  _ProfileSection(
                    title: 'Compte',
                    children: [
                      _ProfileItem(
                        icon: Icons.edit,
                        title: 'Modifier mon profil',
                        onTap: () {
                          AppRouter.openEditProfile(context);
                        },
                      ),
                      _ProfileItem(
                        icon: Icons.calendar_month,
                        title: 'Mes réservations',
                        onTap: () {
                          AppRouter.openMyBookings(context);
                        },
                      ),
                      _ProfileItem(
                        icon: Icons.payment,
                        title: 'Mes paiements',
                        onTap: () {
                          AppRouter.openMyPayments(context);
                        },
                      ),

                      ListTile(
                        leading: const Icon(Icons.mail),
                        title: const Text('Mes invitations'),
                        subtitle: const Text(
                          'Invitations reçues des entreprises',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          AppRouter.openEnterpriseInvitations(context);
                        },
                      ),

                      _ProfileItem(
                        icon: Icons.favorite,
                        title: 'Experts favoris',
                        onTap: () {
                          AppRouter.openFavoriteExperts(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings),
                        title: const Text('Admin Dashboard'),
                        subtitle: const Text('Centre de commandement Mentora'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          AppRouter.openAdminDashboard(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _ProfileSection(
                    title: 'Préférences',
                    children: [
                      _ProfileItem(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        onTap: () {
                          AppRouter.openNotifications(context);
                        },
                      ),
                      _ProfileItem(
                        icon: Icons.dark_mode,
                        title: 'Mode clair / sombre',
                        onTap: () {
                          AppRouter.openAppearance(context);
                        },
                      ),
                      _ProfileItem(icon: Icons.language, title: 'Langue'),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _ProfileSection(
                    title: 'Mentora',
                    children: [
                      const _ProfileItem(
                        icon: Icons.help_outline,
                        title: 'Aide & support',
                      ),
                      _ProfileItem(
                        icon: Icons.workspace_premium,
                        title: 'Tester Espace Expert',
                        onTap: () {
                          AppRouter.openExpertDashboard(
                            context: context,
                            expertId: 'EFRuJcDMP3RYo1VQDnDe',
                          );
                        },
                      ),
                      _ProfileItem(
                        icon: Icons.logout,
                        title: 'Déconnexion',
                        danger: true,
                        onTap: () async {
                          await session.signOut();

                          if (context.mounted) {
                            AppRouter.replaceWithLogin(context);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String fullName;
  final String email;

  const _ProfileHeader({required this.fullName, required this.email});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(MentoraRadius.large),
        boxShadow: MentoraShadows.soft,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 46,
            backgroundColor: MentoraColors.gold,
            child: Icon(
              Icons.person,
              color: isDark ? MentoraColors.navy : Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: MentoraColors.gold.withOpacity(0.14),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Text(
              'Membre Mentora',
              style: TextStyle(
                color: MentoraColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(MentoraRadius.large),
        boxShadow: MentoraShadows.soft,
      ),
      child: const Row(
        children: [
          Expanded(
            child: _StatItem(value: '3', label: 'Sessions'),
          ),
          Expanded(
            child: _StatItem(value: '2', label: 'Experts'),
          ),
          Expanded(
            child: _StatItem(value: '1', label: 'Avis'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: MentoraColors.gold,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(MentoraRadius.large),
            boxShadow: MentoraShadows.soft,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool danger;
  final VoidCallback? onTap;

  const _ProfileItem({
    required this.icon,
    required this.title,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = danger
        ? Colors.redAccent
        : Theme.of(context).textTheme.titleMedium?.color;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: danger ? Colors.redAccent : MentoraColors.gold),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: danger ? Colors.redAccent : Colors.grey,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}
