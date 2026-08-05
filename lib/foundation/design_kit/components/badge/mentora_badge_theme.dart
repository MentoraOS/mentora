import 'dart:ui' show Color;

import 'package:flutter/material.dart' show IconData, Icons;
import 'package:flutter/widgets.dart'
    show Curve, EdgeInsets, EdgeInsetsGeometry;

import '../../appearance/appearance_engine.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../tokens/badge_tokens.dart';
import '../design_kit_scope.dart';
import '../text/mentora_text_role.dart';
import 'mentora_badge_style.dart';

/// What one badge paints — a tinted ground, a delimitation and the
/// accent that names the state.
final class MentoraBadgeVisuals {
  final Color ground;
  final Color border;
  final Color accent;
  final double opacity;

  const MentoraBadgeVisuals({
    required this.ground,
    required this.border,
    required this.accent,
    required this.opacity,
  });
}

/// The Badge Tokens Adapter — the only place where a variant, a form,
/// a size and a state become roles, distances and durations. It
/// consumes the bound engines exclusively.
final class MentoraBadgeTheme {
  final ColorTokenEngine _colors;
  final SpacingTokenEngine _spacing;
  final MotionEngine _motion;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraBadgeTheme({
    required ColorTokenEngine colors,
    required SpacingTokenEngine spacing,
    required MotionEngine motion,
    required AppearanceState appearance,
    required ThemeVariantId variant,
  }) : _colors = colors,
       _spacing = spacing,
       _motion = motion,
       _appearance = appearance,
       _variant = variant;

  /// Builds the adapter from the official consumption channel.
  factory MentoraBadgeTheme.fromScope(DesignKitScope scope) {
    return MentoraBadgeTheme(
      colors: scope.colors,
      spacing: scope.spacing,
      motion: scope.motion,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  BadgeSizeSpec specOf(MentoraBadgeSize size) {
    switch (size) {
      case MentoraBadgeSize.small:
        return smallBadgeSpec;
      case MentoraBadgeSize.medium:
        return mediumBadgeSpec;
      case MentoraBadgeSize.large:
        return largeBadgeSpec;
    }
  }

  EdgeInsetsGeometry paddingOf(MentoraBadgeShape shape, MentoraBadgeSize size) {
    if (!showsWords(shape)) return EdgeInsets.zero;
    return EdgeInsets.symmetric(horizontal: specOf(size).horizontalPadding);
  }

  /// The breathing between a pictogram and its words — a spacing
  /// RELATION, declined by the size's own factor.
  double gapOf(MentoraBadgeSize size) =>
      _spacing.spaceOf(SpacingRelation.proximiteLiee) *
      specOf(size).contentGapFactor;

  double radiusOf(MentoraBadgeShape shape) {
    switch (shape) {
      case MentoraBadgeShape.label:
        return badgeCornerRadius;
      case MentoraBadgeShape.pill:
      case MentoraBadgeShape.dot:
      case MentoraBadgeShape.icon:
      case MentoraBadgeShape.compact:
      case MentoraBadgeShape.extended:
        return badgeFullRadius;
    }
  }

  /// A state change accompanies the information it qualifies — a badge
  /// never announces itself.
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.accompagner, _appearance);

  Curve get curve => _motion.curveFor(MotionIntention.accompagner);

  /// A badge completes an information — it never competes with a
  /// title: only non-structural roles are ever served here.
  MentoraTextRole textRoleOf(MentoraBadgeSize size) {
    switch (size) {
      case MentoraBadgeSize.small:
      case MentoraBadgeSize.medium:
        return MentoraTextRole.caption;
      case MentoraBadgeSize.large:
        return MentoraTextRole.label;
    }
  }

  /// The role that names the state — never a decoration.
  ColorRole accentRoleOf(MentoraBadgeVariant variant) {
    switch (variant) {
      case MentoraBadgeVariant.neutral:
      case MentoraBadgeVariant.custom:
        return ColorRole.neutral;
      case MentoraBadgeVariant.information:
      case MentoraBadgeVariant.sync:
        return ColorRole.information;
      case MentoraBadgeVariant.success:
        return ColorRole.success;
      case MentoraBadgeVariant.warning:
        return ColorRole.warning;
      case MentoraBadgeVariant.critical:
        return ColorRole.critical;
      case MentoraBadgeVariant.verified:
        return ColorRole.verified;
      case MentoraBadgeVariant.premium:
        return ColorRole.secondary;
      case MentoraBadgeVariant.ai:
        return ColorRole.aiSuggestion;
      case MentoraBadgeVariant.offline:
        return ColorRole.unavailable;
    }
  }

  /// The colour role the words speak with — a role, never a colour:
  /// what is unavailable or archived speaks its own state, not its
  /// meaning.
  ColorRole textColorRoleOf({
    required MentoraBadgeVariant variant,
    required MentoraBadgeState state,
  }) {
    switch (state) {
      case MentoraBadgeState.disabled:
        return ColorRole.unavailable;
      case MentoraBadgeState.archived:
        return ColorRole.neutral;
      case MentoraBadgeState.idle:
      case MentoraBadgeState.highlighted:
      case MentoraBadgeState.selected:
      case MentoraBadgeState.processing:
        return accentRoleOf(variant);
    }
  }

  /// The pictogram of the state — a second reading, never the only
  /// one: a form without words always states its meaning (AFS-01).
  IconData iconOf(MentoraBadgeVariant variant) {
    switch (variant) {
      case MentoraBadgeVariant.information:
        return Icons.info_outline;
      case MentoraBadgeVariant.success:
        return Icons.check_circle_outline;
      case MentoraBadgeVariant.warning:
        return Icons.warning_amber_outlined;
      case MentoraBadgeVariant.critical:
        return Icons.error_outline;
      case MentoraBadgeVariant.verified:
        return Icons.verified_outlined;
      case MentoraBadgeVariant.premium:
        return Icons.workspace_premium_outlined;
      case MentoraBadgeVariant.ai:
        return Icons.auto_awesome_outlined;
      case MentoraBadgeVariant.offline:
        return Icons.cloud_off_outlined;
      case MentoraBadgeVariant.sync:
        return Icons.sync_outlined;
      case MentoraBadgeVariant.neutral:
      case MentoraBadgeVariant.custom:
        return Icons.circle_outlined;
    }
  }

  MentoraBadgeVisuals visualsOf({
    required MentoraBadgeVariant variant,
    required MentoraBadgeState state,
  }) {
    final accent = _role(accentRoleOf(variant));
    switch (state) {
      case MentoraBadgeState.disabled:
        final unavailable = _role(ColorRole.unavailable);
        return MentoraBadgeVisuals(
          ground: _role(ColorRole.disabled),
          border: _role(ColorRole.disabled),
          accent: unavailable,
          opacity: badgeDisabledVeilOpacity,
        );
      case MentoraBadgeState.archived:
        // A memory stays readable, never loud.
        return MentoraBadgeVisuals(
          ground: _role(ColorRole.neutral).withValues(
            alpha: badgeGroundOpacity,
          ),
          border: _role(ColorRole.outline),
          accent: _role(ColorRole.neutral),
          opacity: badgeArchivedOpacity,
        );
      case MentoraBadgeState.highlighted:
      case MentoraBadgeState.selected:
        // What is brought forward is filled by its own accent.
        return MentoraBadgeVisuals(
          ground: accent.withValues(alpha: badgeGroundOpacity * 2),
          border: accent,
          accent: accent,
          opacity: badgeFullOpacity,
        );
      case MentoraBadgeState.idle:
      case MentoraBadgeState.processing:
        return MentoraBadgeVisuals(
          ground: accent.withValues(alpha: badgeGroundOpacity),
          border: accent.withValues(alpha: badgeGroundOpacity * 2),
          accent: accent,
          opacity: badgeFullOpacity,
        );
    }
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
