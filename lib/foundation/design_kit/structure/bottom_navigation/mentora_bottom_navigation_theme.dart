import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter/widgets.dart'
    show Curve, EdgeInsets, EdgeInsetsGeometry;

import '../../accessibility/accessibility_engine.dart';
import '../../appearance/appearance_engine.dart';
import '../../components/design_kit_scope.dart';
import '../../components/text/mentora_text_role.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../tokens/bottom_navigation_tokens.dart';
import 'mentora_bottom_navigation_style.dart';

/// What the structure itself paints — the ground it rests on and the
/// line it shares with the content above it.
final class MentoraBottomNavigationVisuals {
  final Color surface;
  final Color divider;

  const MentoraBottomNavigationVisuals({
    required this.surface,
    required this.divider,
  });
}

/// What one destination paints in one state.
final class MentoraBottomNavigationDestinationVisuals {
  final Color? indicator;
  final Color mark;
  final ColorRole wordsRole;
  final double opacity;

  const MentoraBottomNavigationDestinationVisuals({
    required this.indicator,
    required this.mark,
    required this.wordsRole,
    required this.opacity,
  });
}

/// The Bottom Navigation Tokens Adapter — the only place where a state
/// becomes a role, an extent or a duration.
///
/// It resolves the structure's own ground and the expression of its
/// destinations; the words, the states and the values are resolved by
/// the components that own them.
final class MentoraBottomNavigationTheme {
  final ColorTokenEngine _colors;
  final SurfaceTokenEngine _surfaces;
  final SpacingTokenEngine _spacing;
  final MotionEngine _motion;
  final AccessibilityEngine _accessibility;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraBottomNavigationTheme({
    required ColorTokenEngine colors,
    required SurfaceTokenEngine surfaces,
    required SpacingTokenEngine spacing,
    required MotionEngine motion,
    required AccessibilityEngine accessibility,
    required AppearanceState appearance,
    required ThemeVariantId variant,
  }) : _colors = colors,
       _surfaces = surfaces,
       _spacing = spacing,
       _motion = motion,
       _accessibility = accessibility,
       _appearance = appearance,
       _variant = variant;

  /// Builds the adapter from the official consumption channel.
  factory MentoraBottomNavigationTheme.fromScope(DesignKitScope scope) {
    return MentoraBottomNavigationTheme(
      colors: scope.colors,
      surfaces: scope.surfaces,
      spacing: scope.spacing,
      motion: scope.motion,
      accessibility: scope.accessibility,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// The principal level never announces itself: it shows the
  /// continuity of the place the person is in.
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.montrerLaContinuite, _appearance);

  Curve get curve => _motion.curveFor(MotionIntention.montrerLaContinuite);

  /// The band the structure asks for: the compact height it was
  /// designed at, and never less than one reachable target.
  ///
  /// It is a MINIMUM: when the words grow with the font scale, the
  /// structure grows with them rather than clipping them.
  double get extent =>
      math.max(bottomNavigationTokens.height, _accessibility.minimumTapTarget);

  /// A destination is a target: it honors the opposable minimum,
  /// whatever the band proposes.
  double get destinationExtent => _accessibility.minimumTapTarget;

  EdgeInsetsGeometry get padding => EdgeInsets.symmetric(
    horizontal: _spacing.spaceOf(SpacingRelation.proximiteLiee),
  );

  /// A structure never competes with the content: its words stay a
  /// label, never a title.
  MentoraTextRole get wordsRole => MentoraTextRole.label;

  MentoraBottomNavigationVisuals get visuals => MentoraBottomNavigationVisuals(
    surface: _surfaces.surfaceOf(SurfaceRole.primarySurface, _variant),
    divider: _role(ColorRole.divider),
  );

  MentoraBottomNavigationDestinationVisuals destinationVisualsOf(
    MentoraBottomNavigationState state,
  ) {
    switch (state) {
      case MentoraBottomNavigationState.selected:
        // Where the person is: the identity role, on its own ground.
        return MentoraBottomNavigationDestinationVisuals(
          indicator: _role(ColorRole.highlight),
          mark: _role(ColorRole.primary),
          wordsRole: ColorRole.primary,
          opacity: bottomNavigationFullOpacity,
        );
      case MentoraBottomNavigationState.focused:
        return MentoraBottomNavigationDestinationVisuals(
          indicator: _role(
            ColorRole.focus,
          ).withValues(alpha: bottomNavigationIndicatorOpacity),
          mark: _role(ColorRole.focus),
          wordsRole: ColorRole.focus,
          opacity: bottomNavigationFullOpacity,
        );
      case MentoraBottomNavigationState.hovered:
        return MentoraBottomNavigationDestinationVisuals(
          indicator: _role(
            ColorRole.highlight,
          ).withValues(alpha: bottomNavigationIndicatorOpacity),
          mark: _role(ColorRole.supporting),
          wordsRole: ColorRole.supporting,
          opacity: bottomNavigationFullOpacity,
        );
      case MentoraBottomNavigationState.disabled:
        // A place that cannot be reached is veiled — never removed:
        // the person keeps seeing that it exists.
        return MentoraBottomNavigationDestinationVisuals(
          indicator: null,
          mark: _role(ColorRole.unavailable),
          wordsRole: ColorRole.unavailable,
          opacity: bottomNavigationDisabledVeilOpacity,
        );
      case MentoraBottomNavigationState.idle:
        return MentoraBottomNavigationDestinationVisuals(
          indicator: null,
          mark: _role(ColorRole.supporting),
          wordsRole: ColorRole.supporting,
          opacity: bottomNavigationFullOpacity,
        );
    }
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
