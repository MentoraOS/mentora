/// The semantic roles of the catalog (P11.9B) as runtime contracts —
/// names only, never a value. These enums are the receiving structure
/// for the admitted Tokens: adding a role here requires the upstream
/// admission first (UTS-01), never the reverse.
library;

/// The 27 color roles (catalog §D1) — six groups, exactly.
enum ColorRole {
  // Identity.
  primary,
  secondary,
  supporting,
  // Signification.
  information,
  success,
  warning,
  critical,
  neutral,
  // State.
  unavailable,
  disabled,
  attention,
  focus,
  highlight,
  // Interaction and navigation.
  action,
  selection,
  navigation,
  immersion,
  // Trust and AI.
  verified,
  declared,
  prediction,
  estimate,
  aiSuggestion,
  // Environment.
  background,
  surface,
  foreground,
  outline,
  divider,
}

/// The 27 typography roles (catalog §D2) — five groups, exactly.
enum TypographyRole {
  // Structure.
  display,
  hero,
  pageTitle,
  sectionTitle,
  surfaceTitle,
  blockTitle,
  // Body.
  body,
  label,
  supporting,
  caption,
  hint,
  metadata,
  timestamp,
  footnote,
  legal,
  // Data and states.
  value,
  status,
  emptyState,
  loading,
  // Interaction.
  action,
  navigation,
  message,
  // Signification.
  aiSuggestion,
  verification,
  warning,
  critical,
  success,
}

/// The 8 spacing relations (catalog §D3).
enum SpacingRelation {
  proximiteLiee,
  separationDistincte,
  respirationHierarchique,
  contractionCalme,
  cadenceVerticale,
  respirationIntention,
  espaceFocus,
  aireSaisie,
}

/// The official surfaces (Elevation & Surface — the containers and the
/// scene, per the F1.1 brief and catalog §D4).
enum SurfaceRole {
  scene,
  primarySurface,
  secondarySurface,
  protectedSurface,
  immersiveSurface,
}

/// The 4 elevation meanings (catalog §D4) — meanings, never heights.
enum ElevationMeaning { aparte, decision, immersion, signalement }
