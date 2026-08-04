import 'package:flutter/widgets.dart';

import '../accessibility/accessibility_engine.dart';
import '../appearance/appearance_engine.dart';
import '../motion/motion_engine.dart';
import '../registry/token_engines.dart';
import '../theme/theme_variant.dart';

/// The official consumption channel of the Core Components.
///
/// Every Mentora component reads the bound token engines, the current
/// appearance and the resolved theme variant HERE — never through a
/// locator, never through a shared BuildContext, never by re-resolving
/// the theme itself. The application installs the scope exactly once;
/// a component built outside it refuses to build (fail closed).
final class DesignKitScope extends InheritedWidget {
  final ColorTokenEngine colors;
  final TypographyTokenEngine typography;
  final SpacingTokenEngine spacing;
  final SurfaceTokenEngine surfaces;
  final MotionEngine motion;
  final AccessibilityEngine accessibility;
  final AppearanceState appearance;
  final ThemeVariantId variant;

  const DesignKitScope({
    super.key,
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.surfaces,
    required this.motion,
    required this.accessibility,
    required this.appearance,
    required this.variant,
    required super.child,
  });

  /// Derives a scope from an installed one, overriding only the
  /// appearance or the resolved variant. Reserved for surfaces that
  /// legitimately present another variant than the running one — the
  /// living documentation of the Design System. The engines are never
  /// substituted: the same bound Tokens serve every derivation.
  factory DesignKitScope.deriving(
    DesignKitScope parent, {
    ThemeVariantId? variant,
    AppearanceState? appearance,
    required Widget child,
  }) {
    return DesignKitScope(
      colors: parent.colors,
      typography: parent.typography,
      spacing: parent.spacing,
      surfaces: parent.surfaces,
      motion: parent.motion,
      accessibility: parent.accessibility,
      appearance: appearance ?? parent.appearance,
      variant: variant ?? parent.variant,
      child: child,
    );
  }

  static DesignKitScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<DesignKitScope>();
    if (scope == null) {
      throw StateError(
        'DesignKitScope is absent: a Mentora component never builds '
        'outside the Design Kit (install the scope at the root).',
      );
    }
    return scope;
  }

  @override
  bool updateShouldNotify(DesignKitScope oldWidget) {
    return appearance != oldWidget.appearance || variant != oldWidget.variant;
  }
}
