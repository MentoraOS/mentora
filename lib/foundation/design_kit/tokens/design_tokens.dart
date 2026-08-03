/// THE TOKENS LAYER — the only layer that knows values (FDT-02).
///
/// Every value below materializes a Token admitted in the Token Registry
/// Catalog (P11.9B) under its stable name. Values are the v1
/// materialization; they may evolve freely — the names and meanings
/// never do (DTV-03: same Token, several value sets).
///
/// No other file in the foundation may contain a color, a duration, a
/// size or a curve literal — enforced by the foundation governance
/// tests.
library;

import 'package:flutter/widgets.dart';

/// Color roles — catalog §D1, materialized per theme variant.
final class ColorTokenSet {
  // Identity roles.
  final Color primary; // Accent: Mentora Emerald is the official accent.
  final Color onPrimary;
  final Color secondary;
  final Color supporting;

  // Signification roles.
  final Color information;
  final Color success;
  final Color warning;
  final Color critical;
  final Color onCritical;

  // State roles.
  final Color unavailable;
  final Color disabled;
  final Color attention;
  final Color focus;
  final Color highlight;

  // Environment roles.
  final Color background;
  final Color surface;
  final Color foreground;
  final Color mutedForeground;
  final Color outline;
  final Color divider;

  const ColorTokenSet({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.supporting,
    required this.information,
    required this.success,
    required this.warning,
    required this.critical,
    required this.onCritical,
    required this.unavailable,
    required this.disabled,
    required this.attention,
    required this.focus,
    required this.highlight,
    required this.background,
    required this.surface,
    required this.foreground,
    required this.mutedForeground,
    required this.outline,
    required this.divider,
  });
}

/// Mentora Emerald — the official accent (Global Experience §5).
const Color mentoraEmerald = Color(0xFF0E8A6A);

/// Light variant of the color roles (Theme: Light).
const ColorTokenSet lightColorTokens = ColorTokenSet(
  primary: mentoraEmerald,
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF2E5E51),
  supporting: Color(0xFF87A79D),
  information: Color(0xFF3A6EA5),
  success: Color(0xFF2E7D5B),
  warning: Color(0xFF9A6B14),
  critical: Color(0xFFB3403A),
  onCritical: Color(0xFFFFFFFF),
  unavailable: Color(0xFF8C948F),
  disabled: Color(0xFFB9C0BC),
  attention: Color(0xFF9A6B14),
  focus: mentoraEmerald,
  highlight: Color(0xFFDDF0E9),
  background: Color(0xFFF6F9F7),
  surface: Color(0xFFFFFFFF),
  foreground: Color(0xFF191C1B),
  mutedForeground: Color(0xFF5B635F),
  outline: Color(0xFFD3DAD6),
  divider: Color(0xFFE4E9E6),
);

/// Dark variant of the color roles (Theme: Dark).
const ColorTokenSet darkColorTokens = ColorTokenSet(
  primary: Color(0xFF4FC3A1),
  onPrimary: Color(0xFF06251C),
  secondary: Color(0xFF9BC4B7),
  supporting: Color(0xFF6E837B),
  information: Color(0xFF8FB6DE),
  success: Color(0xFF7CC5A4),
  warning: Color(0xFFD9AE5F),
  critical: Color(0xFFE08983),
  onCritical: Color(0xFF2B0907),
  unavailable: Color(0xFF737B76),
  disabled: Color(0xFF4A524D),
  attention: Color(0xFFD9AE5F),
  focus: Color(0xFF4FC3A1),
  highlight: Color(0xFF1E3B32),
  background: Color(0xFF0F1412),
  surface: Color(0xFF181E1B),
  foreground: Color(0xFFE5E9E6),
  mutedForeground: Color(0xFF9AA39E),
  outline: Color(0xFF39413D),
  divider: Color(0xFF272E2A),
);

/// High-contrast variants (Contrast: High) — same names, stronger values.
const ColorTokenSet lightHighContrastColorTokens = ColorTokenSet(
  primary: Color(0xFF075B45),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF1C4437),
  supporting: Color(0xFF4A6A5F),
  information: Color(0xFF1F4E80),
  success: Color(0xFF1C5B3F),
  warning: Color(0xFF6E4A05),
  critical: Color(0xFF8C1F1A),
  onCritical: Color(0xFFFFFFFF),
  unavailable: Color(0xFF5A625D),
  disabled: Color(0xFF8C948F),
  attention: Color(0xFF6E4A05),
  focus: Color(0xFF075B45),
  highlight: Color(0xFFBFE3D7),
  background: Color(0xFFFFFFFF),
  surface: Color(0xFFFFFFFF),
  foreground: Color(0xFF000000),
  mutedForeground: Color(0xFF333936),
  outline: Color(0xFF767E79),
  divider: Color(0xFFB9C0BC),
);

const ColorTokenSet darkHighContrastColorTokens = ColorTokenSet(
  primary: Color(0xFF8FE8CB),
  onPrimary: Color(0xFF00120D),
  secondary: Color(0xFFC4E4D9),
  supporting: Color(0xFF9AB3AA),
  information: Color(0xFFBBD7F3),
  success: Color(0xFFA9E2C7),
  warning: Color(0xFFF0CC8B),
  critical: Color(0xFFF2B3AE),
  onCritical: Color(0xFF1C0503),
  unavailable: Color(0xFFA6AEA9),
  disabled: Color(0xFF737B76),
  attention: Color(0xFFF0CC8B),
  focus: Color(0xFF8FE8CB),
  highlight: Color(0xFF2A4A3F),
  background: Color(0xFF000000),
  surface: Color(0xFF0C100E),
  foreground: Color(0xFFFFFFFF),
  mutedForeground: Color(0xFFCBD2CE),
  outline: Color(0xFF9AA39E),
  divider: Color(0xFF4A524D),
);

/// Spacing relations — catalog §D3. Relative laws, one base measure.
final class SpacingTokenSet {
  final double proximiteLiee;
  final double separationDistincte;
  final double respirationHierarchique;
  final double contractionCalme;
  final double cadenceVerticale;
  final double respirationIntention;
  final double espaceFocus;
  final double aireSaisie;

  const SpacingTokenSet({
    required this.proximiteLiee,
    required this.separationDistincte,
    required this.respirationHierarchique,
    required this.contractionCalme,
    required this.cadenceVerticale,
    required this.respirationIntention,
    required this.espaceFocus,
    required this.aireSaisie,
  });

  /// Density variants decline the same relations (Appearance: Density).
  SpacingTokenSet scaledBy(double factor) {
    return SpacingTokenSet(
      proximiteLiee: proximiteLiee * factor,
      separationDistincte: separationDistincte * factor,
      respirationHierarchique: respirationHierarchique * factor,
      contractionCalme: contractionCalme * factor,
      cadenceVerticale: cadenceVerticale * factor,
      respirationIntention: respirationIntention * factor,
      espaceFocus: espaceFocus * factor,
      aireSaisie: aireSaisie * factor,
    );
  }
}

const SpacingTokenSet standardSpacingTokens = SpacingTokenSet(
  proximiteLiee: 8,
  separationDistincte: 16,
  respirationHierarchique: 24,
  contractionCalme: 12,
  cadenceVerticale: 16,
  respirationIntention: 12,
  espaceFocus: 32,
  aireSaisie: 16,
);

/// Density factors — Appearance: Density (Compact/Standard/Comfortable).
const double compactDensityFactor = 0.85;
const double standardDensityFactor = 1.0;
const double comfortableDensityFactor = 1.2;

/// Typography roles — catalog §D2 (foundation subset: the roles the
/// shell needs today; the full 27 arrive with the component waves).
final class TypographyTokenSet {
  final double pageTitleSize;
  final FontWeight pageTitleWeight;
  final double bodySize;
  final FontWeight bodyWeight;
  final double labelSize;
  final FontWeight labelWeight;
  final double supportingSize;
  final FontWeight supportingWeight;

  const TypographyTokenSet({
    required this.pageTitleSize,
    required this.pageTitleWeight,
    required this.bodySize,
    required this.bodyWeight,
    required this.labelSize,
    required this.labelWeight,
    required this.supportingSize,
    required this.supportingWeight,
  });
}

const TypographyTokenSet typographyTokens = TypographyTokenSet(
  pageTitleSize: 22,
  pageTitleWeight: FontWeight.w600,
  bodySize: 15,
  bodyWeight: FontWeight.w400,
  labelSize: 13,
  labelWeight: FontWeight.w500,
  supportingSize: 13,
  supportingWeight: FontWeight.w400,
);

/// Font scale factors — Appearance: Font Scale (TSA-06: adaptable
/// without breaking hierarchy — a single factor over all roles).
const double smallFontScale = 0.9;
const double standardFontScale = 1.0;
const double largeFontScale = 1.15;
const double extraLargeFontScale = 1.3;
const double minimumFontScale = 0.8;
const double maximumFontScale = 1.6;

/// Fixed-height chrome (the root navigation bar) scales its labels up
/// to this bound only: chrome labels are redundant with their icons
/// and position (AFI-04 — the information is never lost), while the
/// content keeps the full scale (TSA-06).
const double maximumChromeFontScale = 1.2;

/// Interaction requirements — catalog §D9.
final class InteractionTokenSet {
  final double cibleAtteignable;
  final double distanceDeSecurite;
  final Duration immediateteAccuse;

  const InteractionTokenSet({
    required this.cibleAtteignable,
    required this.distanceDeSecurite,
    required this.immediateteAccuse,
  });
}

const InteractionTokenSet interactionTokens = InteractionTokenSet(
  cibleAtteignable: 48,
  distanceDeSecurite: 16,
  immediateteAccuse: Duration(milliseconds: 100),
);

/// Motion intentions — catalog §D10: the eight closed intentions, each
/// with its temporal expression (MT: never slows work down).
final class MotionTokenSet {
  final Duration expliquer;
  final Duration guider;
  final Duration rassurer;
  final Duration preserverLeContexte;
  final Duration attirerLAttention;
  final Duration accompagner;
  final Duration confirmer;
  final Duration montrerLaContinuite;
  final Curve standardCurve;
  final Curve attentionCurve;

  const MotionTokenSet({
    required this.expliquer,
    required this.guider,
    required this.rassurer,
    required this.preserverLeContexte,
    required this.attirerLAttention,
    required this.accompagner,
    required this.confirmer,
    required this.montrerLaContinuite,
    required this.standardCurve,
    required this.attentionCurve,
  });
}

const MotionTokenSet motionTokens = MotionTokenSet(
  expliquer: Duration(milliseconds: 250),
  guider: Duration(milliseconds: 200),
  rassurer: Duration(milliseconds: 180),
  preserverLeContexte: Duration(milliseconds: 250),
  attirerLAttention: Duration(milliseconds: 350),
  accompagner: Duration(milliseconds: 150),
  confirmer: Duration(milliseconds: 220),
  montrerLaContinuite: Duration(milliseconds: 300),
  standardCurve: Curves.easeOutCubic,
  attentionCurve: Curves.easeInOut,
);

/// Reduced-motion factor — Appearance: Motion (Reduced keeps intentions,
/// shortens expressions; None silences them entirely, elsewhere).
const double reducedMotionFactor = 0.5;
