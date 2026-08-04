import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter/material.dart' show IconData, Icons;
import 'package:flutter/widgets.dart'
    show EdgeInsets, EdgeInsetsGeometry, TextStyle;

import '../../accessibility/accessibility_engine.dart';
import '../../appearance/appearance_engine.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../tokens/input_tokens.dart';
import '../design_kit_scope.dart';
import '../text/mentora_text_role.dart';
import 'mentora_input_style.dart';

/// What one field paints in one state — resolved from semantic roles.
/// A null fill or a null border means: nothing is painted there.
final class MentoraInputVisuals {
  final Color? fill;
  final Color? border;
  final double borderWidth;

  /// An underlined field delimits by its base alone — the same border
  /// color, expressed as a single line.
  final bool underlineOnly;

  final double cornerRadius;
  final Color foreground;
  final Color iconColor;

  const MentoraInputVisuals({
    required this.fill,
    required this.border,
    required this.borderWidth,
    required this.underlineOnly,
    required this.cornerRadius,
    required this.foreground,
    required this.iconColor,
  });
}

/// The Input Tokens Adapter — the only place where the field's
/// chrome, availability and states are translated into token roles.
/// It consumes the bound engines exclusively: no color, no size, no
/// duration and no decoration of its own invention.
final class MentoraInputTheme {
  final ColorTokenEngine _colors;
  final TypographyTokenEngine _typography;
  final SurfaceTokenEngine _surfaces;
  final SpacingTokenEngine _spacing;
  final MotionEngine _motion;
  final AccessibilityEngine _accessibility;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraInputTheme({
    required ColorTokenEngine colors,
    required TypographyTokenEngine typography,
    required SurfaceTokenEngine surfaces,
    required SpacingTokenEngine spacing,
    required MotionEngine motion,
    required AccessibilityEngine accessibility,
    required AppearanceState appearance,
    required ThemeVariantId variant,
  }) : _colors = colors,
       _typography = typography,
       _surfaces = surfaces,
       _spacing = spacing,
       _motion = motion,
       _accessibility = accessibility,
       _appearance = appearance,
       _variant = variant;

  /// Builds the adapter from the official consumption channel.
  factory MentoraInputTheme.fromScope(DesignKitScope scope) {
    return MentoraInputTheme(
      colors: scope.colors,
      typography: scope.typography,
      surfaces: scope.surfaces,
      spacing: scope.spacing,
      motion: scope.motion,
      accessibility: scope.accessibility,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  InputSizeSpec specOf(MentoraInputSize size) {
    switch (size) {
      case MentoraInputSize.small:
        return smallInputSpec;
      case MentoraInputSize.medium:
        return mediumInputSpec;
      case MentoraInputSize.large:
        return largeInputSpec;
    }
  }

  /// The effective minimum extent: the token proposes, the opposable
  /// reachable target prevails (AFR-02).
  double minimumExtentOf(MentoraInputSize size) {
    return math.max(specOf(size).height, _accessibility.minimumTapTarget);
  }

  EdgeInsetsGeometry paddingOf(MentoraInputSize size) =>
      EdgeInsets.symmetric(horizontal: specOf(size).horizontalPadding);

  /// The distance between the field and what explains it — a spacing
  /// relation, never a measured gap.
  double get labelGap => _spacing.spaceOf(SpacingRelation.proximiteLiee);

  /// A field accompanies the writing; a refused value must be seen —
  /// the intention changes with the meaning, never the duration with
  /// the mood.
  Duration transitionDurationFor(MentoraInputState state) {
    final intention =
        state == MentoraInputState.invalid || state == MentoraInputState.error
        ? MotionIntention.attirerLAttention
        : MotionIntention.accompagner;
    return _motion.durationFor(intention, _appearance);
  }

  TextStyle valueStyle(MentoraInputVisuals visuals) {
    return _typography
        .styleOf(TypographyRole.body, _variant)
        .copyWith(color: visuals.foreground);
  }

  /// The placeholder speaks the hint role — a suggestion, never a
  /// value and never a label (AFI-04: it replaces no label).
  MentoraTextRole get placeholderRole =>
      const MentoraTextRole.of(TypographyRole.hint);

  MentoraTextRole get labelRole => MentoraTextRole.label;

  /// What explains the field speaks with the meaning of its state.
  MentoraTextRole messageRoleFor(MentoraInputState state) {
    switch (state) {
      case MentoraInputState.invalid:
      case MentoraInputState.error:
        return const MentoraTextRole.of(TypographyRole.critical);
      case MentoraInputState.valid:
      case MentoraInputState.success:
        return const MentoraTextRole.of(TypographyRole.success);
      case MentoraInputState.idle:
      case MentoraInputState.focused:
      case MentoraInputState.typing:
      case MentoraInputState.filled:
      case MentoraInputState.loading:
      case MentoraInputState.disabled:
      case MentoraInputState.readOnly:
        return MentoraTextRole.caption;
    }
  }

  /// The validation icon — a second reading of the verdict, never the
  /// only one: the message always carries the meaning (AFS-01).
  IconData? validationIconFor(MentoraInputState state) {
    switch (state) {
      case MentoraInputState.invalid:
      case MentoraInputState.error:
        return Icons.error_outline;
      case MentoraInputState.valid:
      case MentoraInputState.success:
        return Icons.check_circle_outline;
      case MentoraInputState.idle:
      case MentoraInputState.focused:
      case MentoraInputState.typing:
      case MentoraInputState.filled:
      case MentoraInputState.loading:
      case MentoraInputState.disabled:
      case MentoraInputState.readOnly:
        return null;
    }
  }

  MentoraInputVisuals visualsOf({
    required MentoraInputVariant variant,
    required MentoraInputState state,
  }) {
    final base = _base(variant);
    switch (state) {
      case MentoraInputState.disabled:
        return _recolor(
          base,
          fill: _surface(SurfaceRole.secondarySurface),
          border: base.border == null ? null : _role(ColorRole.disabled),
          foreground: _role(ColorRole.unavailable),
        );
      case MentoraInputState.readOnly:
        // Read-only is not unavailable: the value stays fully
        // readable, only the writing is closed.
        return _recolor(
          base,
          fill: _surface(SurfaceRole.secondarySurface),
          border: base.border,
          foreground: base.foreground,
        );
      case MentoraInputState.invalid:
      case MentoraInputState.error:
        return _delimited(base, _role(ColorRole.critical), inputBorderWidth);
      case MentoraInputState.valid:
      case MentoraInputState.success:
        return _delimited(base, _role(ColorRole.success), inputBorderWidth);
      case MentoraInputState.focused:
      case MentoraInputState.typing:
        return _delimited(base, _role(ColorRole.focus), inputFocusRingWidth);
      case MentoraInputState.loading:
      case MentoraInputState.filled:
      case MentoraInputState.idle:
        return base;
    }
  }

  MentoraInputVisuals _base(MentoraInputVariant variant) {
    final foreground = _role(ColorRole.foreground);
    switch (variant) {
      case MentoraInputVariant.filled:
        return MentoraInputVisuals(
          fill: _surface(SurfaceRole.secondarySurface),
          border: null,
          borderWidth: inputBorderWidth,
          underlineOnly: false,
          cornerRadius: inputCornerRadius,
          foreground: foreground,
          iconColor: _role(ColorRole.supporting),
        );
      case MentoraInputVariant.outlined:
      case MentoraInputVariant.secure:
        return MentoraInputVisuals(
          fill: _surface(SurfaceRole.primarySurface),
          border: _role(ColorRole.outline),
          borderWidth: inputBorderWidth,
          underlineOnly: false,
          cornerRadius: inputCornerRadius,
          foreground: foreground,
          iconColor: _role(ColorRole.supporting),
        );
      case MentoraInputVariant.underlined:
        return MentoraInputVisuals(
          fill: null,
          border: _role(ColorRole.outline),
          borderWidth: inputUnderlineWidth,
          underlineOnly: true,
          cornerRadius: inputCornerRadius,
          foreground: foreground,
          iconColor: _role(ColorRole.supporting),
        );
      case MentoraInputVariant.search:
        return MentoraInputVisuals(
          fill: _surface(SurfaceRole.secondarySurface),
          border: null,
          borderWidth: inputBorderWidth,
          underlineOnly: false,
          cornerRadius: inputSearchCornerRadius,
          foreground: foreground,
          iconColor: _role(ColorRole.supporting),
        );
    }
  }

  /// A delimitation always exists when the state must be seen — even
  /// on a chrome that carries none at rest: a refusal is never silent.
  MentoraInputVisuals _delimited(
    MentoraInputVisuals base,
    Color color,
    double width,
  ) {
    return MentoraInputVisuals(
      fill: base.fill,
      border: color,
      borderWidth: width,
      underlineOnly: base.underlineOnly,
      cornerRadius: base.cornerRadius,
      foreground: base.foreground,
      iconColor: color,
    );
  }

  MentoraInputVisuals _recolor(
    MentoraInputVisuals base, {
    required Color? fill,
    required Color? border,
    required Color foreground,
  }) {
    return MentoraInputVisuals(
      fill: fill,
      border: border,
      borderWidth: base.borderWidth,
      underlineOnly: base.underlineOnly,
      cornerRadius: base.cornerRadius,
      foreground: foreground,
      iconColor: base.iconColor,
    );
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);

  Color _surface(SurfaceRole role) => _surfaces.surfaceOf(role, _variant);
}
