/// The form contracts — Shape, Radius, Border, Opacity — as roles
/// only. No value, no measure, no style lives here.
///
/// These roles are prepared receiving structure: their Tokens are not
/// yet in the catalog (they belong to the Elevation & Surface / Surface
/// standards to come). Per UTS-01, their admission happens upstream
/// first — the Kit is simply ready to receive them without change.
library;

/// What a shape encloses — the container's responsibility, never its
/// geometry (Content Containment).
enum ShapeRole { block, section, surface, decisionEnclosure }

/// The rounding intents — softness serves calm, never fashion.
enum RadiusRole { none, container, enclosure, full }

/// The delimitation intents (rôles Outline/Divider du Color System,
/// portés en forme).
enum BorderRole { outline, divider, focusRing }

/// The translucency intents — always meaningful, never decorative:
/// a scrim protects focus, a disabled veil states unavailability.
enum OpacityRole { disabledVeil, scrim, overlay }
