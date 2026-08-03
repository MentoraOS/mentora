import 'package:flutter/material.dart';

import '../design_kit/accessibility/accessibility_engine.dart';
import '../design_kit/appearance/appearance_engine.dart';
import '../design_kit/tokens/design_tokens.dart';
import '../localization/mentora_strings.dart';

/// The official root navigation (P9.0 MF-04): five entries, one per
/// platform — Home, Consultation, Business, Notifications, Account.
/// AI lives inside Account. No business screen exists yet: each entry
/// hosts its calm foundation surface until its platform waves arrive.
///
/// No logic lives here (no calculation, no decision): the shell only
/// carries the official root movement.
final class NavigationShell extends StatefulWidget {
  final AppearanceEngine appearance;
  final AccessibilityEngine accessibility;

  const NavigationShell({
    super.key,
    required this.appearance,
    required this.accessibility,
  });

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

final class _NavigationShellState extends State<NavigationShell> {
  int _selectedIndex = 0;

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
    final titles = [
      strings.tabHome,
      strings.tabConsultation,
      strings.tabBusiness,
      strings.tabNotifications,
      strings.tabAccount,
    ];

    return Scaffold(
      body: SafeArea(
        child: _FoundationSurface(
          title: titles[_selectedIndex],
          spacing: _spacing,
        ),
      ),
      // Fixed-height chrome renders under the bounded chrome scale:
      // labels stay readable, the layout never overflows, and the
      // information stays complete through the icons (AFI-04).
      bottomNavigationBar: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(
            widget.accessibility.chromeTextScaleFor(widget.appearance.state),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: strings.tabHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.event_note_outlined),
              selectedIcon: const Icon(Icons.event_note),
              label: strings.tabConsultation,
            ),
            NavigationDestination(
              icon: const Icon(Icons.insights_outlined),
              selectedIcon: const Icon(Icons.insights),
              label: strings.tabBusiness,
            ),
            NavigationDestination(
              icon: const Icon(Icons.notifications_outlined),
              selectedIcon: const Icon(Icons.notifications),
              label: strings.tabNotifications,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: strings.tabAccount,
            ),
          ],
        ),
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
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.all(spacing.separationDistincte),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleLarge),
          SizedBox(height: spacing.cadenceVerticale),
          Text(strings.nothingNeedsAttention, style: textTheme.bodyMedium),
          SizedBox(height: spacing.respirationIntention),
          Text(strings.foundationReadyBody, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
