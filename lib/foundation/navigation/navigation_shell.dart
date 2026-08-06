import 'package:flutter/material.dart';

import '../design_kit/appearance/appearance_engine.dart';
import '../design_kit/components/text/mentora_text.dart';
import '../design_kit/components/text/mentora_text_role.dart';
import '../design_kit/structure/bottom_navigation/mentora_bottom_navigation.dart';
import '../design_kit/structure/bottom_navigation/mentora_bottom_navigation_style.dart';
import '../design_kit/structure/page_scaffold/mentora_page_scaffold.dart';
import '../design_kit/tokens/design_tokens.dart';
import '../localization/mentora_strings.dart';

/// The official root navigation (P9.0 MF-04): five entries, one per
/// platform — Home, Consultation, Business, Notifications, Account.
/// AI lives inside Account. No business screen exists yet: each entry
/// hosts its calm foundation surface until its platform waves arrive.
///
/// The shell owns NO navigation component: the page and its principal
/// level are Structural Components of the Design Kit. What lives here
/// is what belongs to the application alone — the identities of the
/// product, and the place the person is in.
final class NavigationShell extends StatefulWidget {
  final AppearanceEngine appearance;

  const NavigationShell({super.key, required this.appearance});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

final class _NavigationShellState extends State<NavigationShell> {
  /// The identities of the principal level — never positions, and
  /// stable for as long as the product exists.
  static const String _home = 'home';
  static const String _consultation = 'consultation';
  static const String _business = 'business';
  static const String _notifications = 'notifications';
  static const String _account = 'account';

  /// Where the person is. The application decides it — the structure
  /// only reports what was asked for.
  String _selectedId = _home;

  SpacingTokenSet get _spacing {
    final double factor;
    switch (widget.appearance.state.density) {
      case DensityPreference.compact:
        factor = compactDensityFactor;
      case DensityPreference.standard:
        factor = standardDensityFactor;
      case DensityPreference.comfortable:
        factor = comfortableDensityFactor;
    }
    return standardSpacingTokens.scaledBy(factor);
  }

  @override
  Widget build(BuildContext context) {
    final strings = MentoraStrings.of(context);
    final destinations = <MentoraBottomNavigationDestination>[
      MentoraBottomNavigationDestination(
        id: _home,
        label: strings.tabHome,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
      MentoraBottomNavigationDestination(
        id: _consultation,
        label: strings.tabConsultation,
        icon: Icons.event_note_outlined,
        selectedIcon: Icons.event_note,
      ),
      MentoraBottomNavigationDestination(
        id: _business,
        label: strings.tabBusiness,
        icon: Icons.insights_outlined,
        selectedIcon: Icons.insights,
      ),
      MentoraBottomNavigationDestination(
        id: _notifications,
        label: strings.tabNotifications,
        icon: Icons.notifications_outlined,
        selectedIcon: Icons.notifications,
      ),
      MentoraBottomNavigationDestination(
        id: _account,
        label: strings.tabAccount,
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
      ),
    ];
    final current = destinations.firstWhere((place) => place.id == _selectedId);

    return MentoraPageScaffold(
      semanticLabel: current.label,
      content: _FoundationSurface(title: current.label, spacing: _spacing),
      bottomNavigation: MentoraBottomNavigation(
        semanticLabel: strings.rootNavigation,
        destinations: destinations,
        selectedDestinationId: _selectedId,
        // The structure reports the identity; the application decides
        // what happens next.
        onDestinationRequested: (id) => setState(() => _selectedId = id),
      ),
    );
  }
}

/// The calm foundation surface: an honest, designed placeholder — the
/// assumed empty state (EV-03), never a fake screen.
final class _FoundationSurface extends StatelessWidget {
  final String title;
  final SpacingTokenSet spacing;

  const _FoundationSurface({required this.title, required this.spacing});

  @override
  Widget build(BuildContext context) {
    final strings = MentoraStrings.of(context);

    return Padding(
      padding: EdgeInsets.all(spacing.separationDistincte),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(title, role: MentoraTextRole.title),
          SizedBox(height: spacing.cadenceVerticale),
          MentoraText(
            strings.nothingNeedsAttention,
            role: MentoraTextRole.body,
          ),
          SizedBox(height: spacing.respirationIntention),
          MentoraText(
            strings.foundationReadyBody,
            role: MentoraTextRole.caption,
          ),
        ],
      ),
    );
  }
}
