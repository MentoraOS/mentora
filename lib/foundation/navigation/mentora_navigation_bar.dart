import 'package:flutter/material.dart';

import '../design_kit/appearance/appearance_engine.dart';
import '../design_kit/components/design_kit_scope.dart';
import '../design_kit/motion/motion_engine.dart';
import '../design_kit/registry/semantic_roles.dart';
import '../design_kit/tokens/navigation_bar_tokens.dart';

/// One entry of the root navigation — icon pair and label, nothing
/// else (the shell provides localized labels; this component never
/// codes a string).
final class MentoraNavigationDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const MentoraNavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// The official compact root navigation bar of Mentora.
///
/// Ergonomics: a 60–64 dp bar, one-line 11 sp labels, a discreet
/// Mentora-Emerald active capsule (highlight role — never a shout),
/// homogeneous icon pairs, and sober motion (the `accompagner`
/// intention, declined by the Motion preference — None silences it).
///
/// Every dimension, color and text style comes from the Design Kit:
/// dimensions from the navigation bar tokens, colors from the
/// token-built theme, durations from the Motion Engine. No value is
/// coded here — enforced by the governance scans.
final class MentoraNavigationBar extends StatelessWidget {
  final List<MentoraNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final MotionEngine motion;
  final AppearanceState appearance;

  const MentoraNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.motion,
    required this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.navigationBarTheme.backgroundColor ??
          theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: navigationBarTokens.height,
          child: Column(
            children: [
              Divider(
                height: DividerTheme.of(context).thickness ?? 1,
                thickness: DividerTheme.of(context).thickness ?? 1,
                color: theme.dividerColor,
              ),
              Expanded(
                child: Row(
                  children: [
                    for (var index = 0; index < destinations.length; index++)
                      Expanded(
                        child: _MentoraNavigationItem(
                          destination: destinations[index],
                          selected: index == selectedIndex,
                          onTap: () => onDestinationSelected(index),
                          motion: motion,
                          appearance: appearance,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _MentoraNavigationItem extends StatelessWidget {
  final MentoraNavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final MotionEngine motion;
  final AppearanceState appearance;

  const _MentoraNavigationItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    required this.motion,
    required this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = DesignKitScope.of(context);
    // The chrome speaks roles: the identity when chosen, the
    // supporting voice when at rest — never an ambient TextTheme.
    final color = scope.colors.colorOf(
      selected ? ColorRole.primary : ColorRole.supporting,
      scope.variant,
    );
    final duration = motion.durationFor(
      MotionIntention.accompagner,
      appearance,
    );
    final curve = motion.curveFor(MotionIntention.accompagner);

    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // The discreet active capsule: the highlight role (an
            // emerald tint), never a filled shout.
            AnimatedContainer(
              duration: duration,
              curve: curve,
              padding: EdgeInsets.symmetric(
                horizontal: navigationBarTokens.capsuleHorizontalPadding,
                vertical: navigationBarTokens.capsuleVerticalPadding,
              ),
              decoration: BoxDecoration(
                color: selected ? theme.highlightColor : null,
                borderRadius: BorderRadius.circular(
                  navigationBarTokens.capsuleRadius,
                ),
              ),
              child: Icon(
                selected ? destination.selectedIcon : destination.icon,
                size: navigationBarTokens.iconSize,
                color: color,
              ),
            ),
            SizedBox(height: navigationBarTokens.iconLabelGap),
            Text(
              destination.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: navigationBarLabelStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
