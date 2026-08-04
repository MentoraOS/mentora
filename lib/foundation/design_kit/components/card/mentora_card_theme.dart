import 'dart:ui' show Color, Offset;

import 'package:flutter/widgets.dart'
    show BoxShadow, EdgeInsets, EdgeInsetsGeometry;

import '../../accessibility/accessibility_engine.dart';
import '../../appearance/appearance_engine.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../tokens/card_tokens.dart';
import '../design_kit_scope.dart';
import 'mentora_card_style.dart';

/// What one card paints in one state — surfaces, delimitations and
/// depth, resolved from semantic roles. A null border or a null shadow
/// means: nothing is painted there.
final class MentoraCardVisuals {
  final Color background;
  final Color? border;
  final double borderWidth;
  final List<BoxShadow>? shadow;

  const MentoraCardVisuals({
    required this.background,
    this.border,
    this.borderWidth = cardBorderWidth,
    this.shadow,
  });
}

/// The Card Tokens Adapter — the only place where the container's
/// variants and states are translated into token roles. It consumes
/// the bound engines exclusively; it never holds a value, never a
/// color, never a duration, never a distance.
final class MentoraCardTheme {
  final ColorTokenEngine _colors;
  final SurfaceTokenEngine _surfaces;
  final SpacingTokenEngine _spacing;
  final MotionEngine _motion;
  final AccessibilityEngine _accessibility;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraCardTheme({
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
  factory MentoraCardTheme.fromScope(DesignKitScope scope) {
    return MentoraCardTheme(
      colors: scope.colors,
      surfaces: scope.surfaces,
      spacing: scope.spacing,
      motion: scope.motion,
      accessibility: scope.accessibility,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// A soft shadow is unreliable at high contrast: the raised card
  /// then expresses its depth by a delimitation instead (the opposable
  /// requirement prevails over the visual effect).
  bool get prefersDelimitedDepth =>
      _variant == ThemeVariantId.lightHighContrast ||
      _variant == ThemeVariantId.darkHighContrast ||
      _accessibility.isHighContrast(_appearance);

  /// The inner breathing of the container — a spacing RELATION chosen
  /// by the Density preference, never a distance chosen here.
  SpacingRelation relationForDensity() {
    switch (_appearance.density) {
      case DensityPreference.compact:
        return SpacingRelation.contractionCalme;
      case DensityPreference.standard:
        return SpacingRelation.separationDistincte;
      case DensityPreference.comfortable:
        return SpacingRelation.respirationHierarchique;
    }
  }

  EdgeInsetsGeometry get padding =>
      EdgeInsets.all(_spacing.spaceOf(relationForDensity()));

  /// A card accompanies the context it holds — it never confirms an
  /// act. The Motion preference declines the expression (None
  /// silences it).
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.accompagner, _appearance);

  /// The ink of a pressed or hovered container — the discreet
  /// highlight role, never an invented tint.
  Color get overlay => _role(ColorRole.highlight);

  /// An inviting card is a target: it honors the opposable minimum
  /// like any other reachable surface.
  double get minimumInteractiveExtent => _accessibility.minimumTapTarget;

  MentoraCardVisuals visualsOf({
    required MentoraCardVariant variant,
    required MentoraCardState state,
  }) {
    switch (state) {
      case MentoraCardState.disabled:
        return MentoraCardVisuals(
          background: _surface(SurfaceRole.secondarySurface),
          border: _base(variant).border == null
              ? null
              : _role(ColorRole.disabled),
        );
      case MentoraCardState.loading:
        // The content is not there yet: the container rests on the
        // calm surface and invents nothing to fill the wait.
        return MentoraCardVisuals(
          background: _surface(SurfaceRole.secondarySurface),
          border: _base(variant).border == null
              ? null
              : _role(ColorRole.outline),
        );
      case MentoraCardState.error:
        final base = _base(variant);
        return MentoraCardVisuals(
          background: base.background,
          border: _role(ColorRole.critical),
          shadow: base.shadow,
        );
      case MentoraCardState.focused:
        final base = _base(variant);
        return MentoraCardVisuals(
          background: base.background,
          border: _role(ColorRole.focus),
          borderWidth: cardFocusRingWidth,
          shadow: base.shadow,
        );
      case MentoraCardState.selected:
        return _base(MentoraCardVariant.selected);
      case MentoraCardState.idle:
      case MentoraCardState.pressed:
      case MentoraCardState.hovered:
        return _base(variant);
    }
  }

  MentoraCardVisuals _base(MentoraCardVariant variant) {
    switch (variant) {
      case MentoraCardVariant.surface:
        return MentoraCardVisuals(
          background: _surface(SurfaceRole.primarySurface),
        );
      case MentoraCardVariant.outlined:
        return MentoraCardVisuals(
          background: _surface(SurfaceRole.primarySurface),
          border: _role(ColorRole.outline),
        );
      case MentoraCardVariant.elevated:
        return MentoraCardVisuals(
          background: _surface(SurfaceRole.primarySurface),
          border: prefersDelimitedDepth ? _role(ColorRole.outline) : null,
          shadow: prefersDelimitedDepth ? null : _shadow(),
        );
      case MentoraCardVariant.interactive:
        return MentoraCardVisuals(
          background: _surface(SurfaceRole.primarySurface),
          border: _role(ColorRole.outline),
        );
      case MentoraCardVariant.selected:
        return MentoraCardVisuals(
          background: _role(ColorRole.highlight),
          border: _role(ColorRole.selection),
        );
      case MentoraCardVariant.protected:
        return MentoraCardVisuals(
          background: _surface(SurfaceRole.protectedSurface),
          border: _role(ColorRole.attention),
        );
    }
  }

  /// The diffusion of the environment's ink under a raised container —
  /// a role and an opacity Token, never a painted color.
  List<BoxShadow> _shadow() {
    return [
      BoxShadow(
        color: _role(ColorRole.foreground).withValues(
          alpha: cardShadow.opacity,
        ),
        blurRadius: cardShadow.blurRadius,
        spreadRadius: cardShadow.spreadRadius,
        offset: Offset(0, cardShadow.verticalOffset),
      ),
    ];
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);

  Color _surface(SurfaceRole role) => _surfaces.surfaceOf(role, _variant);
}
