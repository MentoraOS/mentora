import 'dart:ui' show Color;

import 'package:flutter/material.dart' show IconData, Icons;
import 'package:flutter/widgets.dart'
    show Curve, EdgeInsets, EdgeInsetsGeometry;

import '../../appearance/appearance_engine.dart';
import '../../components/text/mentora_text_role.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../tokens/app_bar_tokens.dart';
import '../../components/design_kit_scope.dart';
import 'mentora_app_bar_style.dart';

/// What one context paints — the surface it rests on, its
/// delimitation and how present it is.
final class MentoraAppBarVisuals {
  final Color? surface;
  final Color? divider;
  final Color accent;
  final double opacity;

  const MentoraAppBarVisuals({
    required this.surface,
    required this.divider,
    required this.accent,
    required this.opacity,
  });
}

/// The App Bar Tokens Adapter — the only place where a variant, a
/// state and a collapse progress become roles, extents and durations.
///
/// It resolves the structure's own surface and nothing else: the
/// words, the identity, the states and the acts are resolved by the
/// components that own them.
final class MentoraAppBarTheme {
  final ColorTokenEngine _colors;
  final SurfaceTokenEngine _surfaces;
  final SpacingTokenEngine _spacing;
  final MotionEngine _motion;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraAppBarTheme({
    required ColorTokenEngine colors,
    required SurfaceTokenEngine surfaces,
    required SpacingTokenEngine spacing,
    required MotionEngine motion,
    required AppearanceState appearance,
    required ThemeVariantId variant,
  }) : _colors = colors,
       _surfaces = surfaces,
       _spacing = spacing,
       _motion = motion,
       _appearance = appearance,
       _variant = variant;

  /// Builds the adapter from the official consumption channel.
  factory MentoraAppBarTheme.fromScope(DesignKitScope scope) {
    return MentoraAppBarTheme(
      colors: scope.colors,
      surfaces: scope.surfaces,
      spacing: scope.spacing,
      motion: scope.motion,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// The room a variant reserves. It is a Token and a pure function —
  /// a structure declares its extent before any engine is consulted,
  /// so a host can reserve it without a context.
  static AppBarExtentSpec extentOf(MentoraAppBarVariant variant) {
    switch (variant) {
      case MentoraAppBarVariant.largeTitle:
        return largeTitleAppBarSpec;
      case MentoraAppBarVariant.compact:
        return compactAppBarSpec;
      case MentoraAppBarVariant.standard:
      case MentoraAppBarVariant.transparent:
      case MentoraAppBarVariant.search:
      case MentoraAppBarVariant.modal:
        return standardAppBarSpec;
    }
  }

  /// A context showing the content its room is showing a continuity —
  /// never an entrance, never an announcement of itself.
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.montrerLaContinuite, _appearance);

  Curve get curve => _motion.curveFor(MotionIntention.montrerLaContinuite);

  EdgeInsetsGeometry get padding => EdgeInsets.symmetric(
    horizontal: _spacing.spaceOf(SpacingRelation.separationDistincte),
  );

  double get gap => _spacing.spaceOf(SpacingRelation.proximiteLiee);

  double get actionGap =>
      _spacing.spaceOf(SpacingRelation.proximiteLiee) *
      appBarActionSpacingFactor;

  /// The voice a context speaks with. A large title announces the
  /// place; once collapsed it steps back to the standard voice — the
  /// context never competes with the content.
  MentoraTextRole titleRoleOf({
    required MentoraAppBarVariant variant,
    required double collapseProgress,
  }) {
    if (variant != MentoraAppBarVariant.largeTitle) {
      return MentoraTextRole.subtitle;
    }
    return collapseProgress >= appBarFullOpacity
        ? MentoraTextRole.subtitle
        : MentoraTextRole.title;
  }

  MentoraTextRole get subtitleRole =>
      const MentoraTextRole.of(TypographyRole.supporting);

  IconData iconOf(MentoraAppBarNavigationKind kind) {
    switch (kind) {
      case MentoraAppBarNavigationKind.back:
        return Icons.arrow_back;
      case MentoraAppBarNavigationKind.close:
        return Icons.close;
    }
  }

  MentoraAppBarVisuals visualsOf({
    required MentoraAppBarVariant variant,
    required MentoraAppBarState state,
  }) {
    final transparent = variant == MentoraAppBarVariant.transparent;
    // A context that the content has passed under says so with a
    // delimitation — never with a shadow it invented.
    final separated =
        state == MentoraAppBarState.scrolled ||
        state == MentoraAppBarState.collapsed;

    return MentoraAppBarVisuals(
      surface: transparent
          ? null
          : _surfaces.surfaceOf(SurfaceRole.primarySurface, _variant),
      divider: separated && !transparent ? _role(ColorRole.divider) : null,
      accent: _role(ColorRole.primary),
      opacity: state == MentoraAppBarState.disabled
          ? appBarDisabledVeilOpacity
          : appBarFullOpacity,
    );
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
