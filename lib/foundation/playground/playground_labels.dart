/// Internal developer-tool labels. The playground is not a user
/// interface: these are laboratory captions for engineers, centralized
/// here so no widget codes a string inline.
library;

const String playgroundTitle = 'Mentora Design Kit Playground';
const String coveragePanelTitle = 'Token Coverage';
const String integrityPanelTitle = 'Binding Integrity';
const String runtimePanelTitle = 'Runtime Verification';
const String themeInspectorTitle = 'Theme Inspector';
const String colorGalleryTitle = 'Color Roles (27)';
const String typographyGalleryTitle = 'Typography Roles (27)';
const String spacingGalleryTitle = 'Spacing Relations (8)';
const String surfaceGalleryTitle = 'Surfaces (5)';
const String elevationGalleryTitle = 'Elevation Meanings (4)';
const String responsiveGalleryTitle = 'Responsive Contexts';
const String motionGalleryTitle = 'Motion Intentions (8)';
const String cardGalleryTitle = 'Cards — Variants (6) & States (8)';
const String buttonGalleryTitle = 'Buttons — Variants (6), Sizes (3) & States';
const String textGalleryTitle =
    'Typography — 27 Roles, 4 Variants, Scale, Comfort, Direction';

/// The living documentation of the Text component — rendered by the
/// component itself, never by a substitute.
const String textDocHeading = 'MentoraText — official contract';
const String textDocRolesTitle = 'Available roles';
const String textDocRulesTitle = 'Usage rules';
const String textDocForbiddenTitle = 'Prohibited';
const String textDocTokensTitle = 'Tokens consumed';
const String textDocEnginesTitle = 'Engines consumed';
const List<String> textDocRules = [
  'A screen says a behavior, never a style.',
  'The 10 behaviors designate admitted roles — none is invented.',
  'A color override is a role, never a color.',
  'Overflow is controlled by default: no silent clipping.',
  'Selection is offered only where content is meant to be taken away.',
  'The strings belong to the application, never to the component.',
];
const List<String> textDocForbidden = [
  'Text, RichText, SelectableText, DefaultTextStyle in a screen',
  'A TextStyle built inside a widget',
  'A coded fontSize, FontWeight, Color or family',
  'Reading the ambient TextTheme from the widget tree',
  'A second direction or font-scale authority',
];
const List<String> textDocTokens = [
  'Typography: the 27 admitted role Tokens (catalog §D2)',
  'Color: the role Tokens used by an override (catalog §D1)',
];
const String inputGalleryTitle =
    'Inputs — Chromes (5), Availability (3), Sizes (3) & States (11)';
const String inputDocHeading = 'MentoraInput — official contract';
const String inputDocArchitectureTitle = 'Architecture';
const String inputDocResponsibilitiesTitle = 'Responsibilities';
const String inputDocScansTitle = 'Executable scans';
const List<String> inputDocArchitecture = [
  'Chrome and availability are orthogonal: any chrome can be read-only',
  'The Input Tokens Adapter resolves every state into roles',
  'No InputDecoration exists in Mentora: the component owns its chrome',
  'Label, placeholder and message are MentoraText',
  'The controller carries the phase and the published verdict',
];
const List<String> inputDocResponsibilities = [
  'It carries a value; it judges none',
  'A refusal is never hidden by the focus',
  'Read-only is not unavailable: the value stays readable',
  'A control without a name is never rendered',
  'Direction, IME, composition and autofill belong to the platform',
];
const List<String> inputDocForbidden = [
  'TextField or TextFormField in a screen',
  'InputDecoration, OutlineInputBorder, UnderlineInputBorder',
  'A decoration, padding, radius or border built in a widget',
  'A coded color, size or duration',
  'Reading the ambient Theme from a component',
];
const List<String> inputDocTokens = [
  'Input: heights, paddings, radii, borders, veil (chapter Form)',
  'Color: outline, focus, critical, success, disabled, unavailable',
  'Surface: primary and secondary surfaces',
  'Typography: body, label, hint, caption, critical, success',
  'Spacing: the proximity relation between a field and its message',
];
const List<String> inputDocEngines = [
  'Color, Typography, Surface & Spacing Token Engines',
  'Motion Engine — accompany while writing, attract when refused',
  'Accessibility Engine — the opposable reachable target',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Localization & International Engines — the strings and the direction',
];
const List<String> inputDocScans = [
  'No raw field widget outside the Input component',
  'No InputDecoration anywhere in the foundation',
  'No decoration, radius, padding or border coded outside the Tokens',
  'No ambient Theme read inside a Core Component',
];
const List<String> textDocEngines = [
  'Typography Token Engine — the role becomes a style',
  'Color Token Engine — the override becomes a color',
  'Theme Engine — the variant that serves the Tokens',
  'Accessibility Engine — the font scale, applied once by the app',
  'Appearance Engine — theme, contrast, reading comfort',
  'Localization & International Engines — the strings and the direction',
];
const String runtimeHealthy = 'All verifications passed — fail closed armed.';
const String hardcodedLabel = 'Hardcoded Values';
const String deprecatedLabel = 'Deprecated Tokens';
const String orphanLabel = 'Orphan Tokens';
const String unknownLabel = 'Unknown Tokens';
const String missingLabel = 'Missing Bindings';
const String coverageLabel = 'Coverage';
