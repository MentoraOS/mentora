import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter/widgets.dart' show TextStyle;

import '../../accessibility/accessibility_engine.dart';
import '../../appearance/appearance_engine.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../tokens/button_tokens.dart';
import '../../tokens/color_internals.dart';
import '../design_kit_scope.dart';
import 'mentora_button_style.dart';

/// What one button paints in one state — colors only, resolved from
/// semantic roles. Null background/border means: nothing is painted.
final class MentoraButtonVisuals {
  final Color? background;
  final Color foreground;
  final Color? border;
  final double borderWidth;

  const MentoraButtonVisuals({
    required this.background,
    required this.foreground,
    this.border,
    this.borderWidth = buttonBorderWidth,
  });
}

/// The Button Tokens Adapter — the only place where the button's
/// variants and states are translated into token roles. It consumes
/// the bound engines exclusively; it never holds a value, never a
/// color, never a duration.
final class MentoraButtonTheme {
  final ColorTokenEngine _colors;
  final TypographyTokenEngine _typography;
  final MotionEngine _motion;
  final AccessibilityEngine _accessibility;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraButtonTheme({
    required ColorTokenEngine colors,
    required TypographyTokenEngine typography,
    required MotionEngine motion,
    required AccessibilityEngine accessibility,
    required AppearanceState appearance,
    required ThemeVariantId variant,
  }) : _colors = colors,
       _typography = typography,
       _motion = motion,
       _accessibility = accessibility,
       _appearance = appearance,
       _variant = variant;

  /// Builds the adapter from the official consumption channel.
  factory MentoraButtonTheme.fromScope(DesignKitScope scope) {
    return MentoraButtonTheme(
      colors: scope.colors,
      typography: scope.typography,
      motion: scope.motion,
      accessibility: scope.accessibility,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  ButtonSizeSpec specOf(MentoraButtonSize size) {
    switch (size) {
      case MentoraButtonSize.small:
        return smallButtonSpec;
      case MentoraButtonSize.medium:
        return mediumButtonSpec;
      case MentoraButtonSize.large:
        return largeButtonSpec;
    }
  }

  /// The effective minimum extent: the token proposes, the opposable
  /// reachable target prevails (AFR-02).
  double minimumExtentOf(MentoraButtonSize size) {
    return math.max(specOf(size).height, _accessibility.minimumTapTarget);
  }

  /// State transitions confirm what happened — the confirm intention,
  /// declined by the Motion preference (None silences it).
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.confirmer, _appearance);

  /// The pressed/hovered ink expression — the discreet highlight role.
  Color get pressedOverlay => _role(ColorRole.highlight);

  TextStyle labelStyleOf(MentoraButtonVisuals visuals) {
    return _typography
        .styleOf(buttonTypographyRole, _variant)
        .copyWith(color: visuals.foreground);
  }

  MentoraButtonVisuals visualsOf({
    required MentoraButtonVariant variant,
    required MentoraButtonState state,
  }) {
    switch (state) {
      case MentoraButtonState.disabled:
        return _disabledVisuals(variant);
      case MentoraButtonState.success:
        return _feedbackVisuals(
          variant,
          fill: _role(ColorRole.success),
          onFill: identityInternalsFor(_variant).onPrimary,
        );
      case MentoraButtonState.error:
        return _feedbackVisuals(
          variant,
          fill: _role(ColorRole.critical),
          onFill: identityInternalsFor(_variant).onCritical,
        );
      case MentoraButtonState.focused:
        return _withFocusRing(_baseVisuals(variant));
      case MentoraButtonState.idle:
      case MentoraButtonState.pressed:
      case MentoraButtonState.hovered:
      case MentoraButtonState.loading:
        return _baseVisuals(variant);
    }
  }

  MentoraButtonVisuals _baseVisuals(MentoraButtonVariant variant) {
    final internals = identityInternalsFor(_variant);
    switch (variant) {
      case MentoraButtonVariant.contained:
        return MentoraButtonVisuals(
          background: _role(ColorRole.primary),
          foreground: internals.onPrimary,
        );
      case MentoraButtonVariant.tonal:
        return MentoraButtonVisuals(
          background: _role(ColorRole.highlight),
          foreground: _role(ColorRole.primary),
        );
      case MentoraButtonVariant.outlined:
        return MentoraButtonVisuals(
          background: null,
          foreground: _role(ColorRole.primary),
          border: _role(ColorRole.outline),
        );
      case MentoraButtonVariant.text:
        return MentoraButtonVisuals(
          background: null,
          foreground: _role(ColorRole.primary),
        );
      case MentoraButtonVariant.danger:
        return MentoraButtonVisuals(
          background: _role(ColorRole.critical),
          foreground: internals.onCritical,
        );
      case MentoraButtonVariant.success:
        return MentoraButtonVisuals(
          background: _role(ColorRole.success),
          foreground: internals.onPrimary,
        );
    }
  }

  MentoraButtonVisuals _disabledVisuals(MentoraButtonVariant variant) {
    switch (variant) {
      case MentoraButtonVariant.contained:
      case MentoraButtonVariant.tonal:
      case MentoraButtonVariant.danger:
      case MentoraButtonVariant.success:
        return MentoraButtonVisuals(
          background: _role(ColorRole.disabled),
          foreground: _role(ColorRole.unavailable),
        );
      case MentoraButtonVariant.outlined:
        return MentoraButtonVisuals(
          background: null,
          foreground: _role(ColorRole.unavailable),
          border: _role(ColorRole.disabled),
        );
      case MentoraButtonVariant.text:
        return MentoraButtonVisuals(
          background: null,
          foreground: _role(ColorRole.unavailable),
        );
    }
  }

  /// A transient outcome speaks with the signification roles — filled
  /// variants fill, bordered/text variants tint (IS discreet feedback).
  MentoraButtonVisuals _feedbackVisuals(
    MentoraButtonVariant variant, {
    required Color fill,
    required Color onFill,
  }) {
    switch (variant) {
      case MentoraButtonVariant.contained:
      case MentoraButtonVariant.tonal:
      case MentoraButtonVariant.danger:
      case MentoraButtonVariant.success:
        return MentoraButtonVisuals(background: fill, foreground: onFill);
      case MentoraButtonVariant.outlined:
        return MentoraButtonVisuals(
          background: null,
          foreground: fill,
          border: fill,
        );
      case MentoraButtonVariant.text:
        return MentoraButtonVisuals(background: null, foreground: fill);
    }
  }

  MentoraButtonVisuals _withFocusRing(MentoraButtonVisuals base) {
    return MentoraButtonVisuals(
      background: base.background,
      foreground: base.foreground,
      border: _role(ColorRole.focus),
      borderWidth: buttonFocusRingWidth,
    );
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
