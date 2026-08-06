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
const String navigationRailGalleryTitle =
    'Navigation Rails — Displays (2), Chromes (3) & States (7)';
const String navigationRailDocHeading =
    'MentoraNavigationRail — official contract';
const List<String> navigationRailDocArchitecture = [
  'A Structural Component: it expresses the principal navigation',
  'A destination is an IDENTITY — never an icon, a position or an address',
  'Selection travels by identity: no index exists in its API',
  'It never measures the surface it lives on: the application decides',
  'Its adapter resolves the structure and its destinations only',
];
const List<String> navigationRailDocResponsibilities = [
  'It accompanies: it never competes with the content',
  'It never becomes a menu',
  'It never decides where to go: it reports, the application announces',
  'A place announced that it does not present is refused',
  'Every destination is a reachable target and a keyboard control',
];
const List<String> navigationRailDocComponents = [
  'MentoraAvatar — owns the identity',
  'MentoraText — owns the typography',
  'MentoraBadge — owns what is happening in a place',
  'MentoraButton — owns the acts and the display toggle',
];
const List<String> navigationRailDocForbidden = [
  'The framework rails, drawers and their destinations',
  'Any address, any navigator, any routing known by the structure',
  'Any measure of the screen or responsive decision taken here',
  'A coded colour, size, padding or duration',
  'Reading the ambient Theme from a component',
];
const List<String> navigationRailDocTokens = [
  'Navigation Rail: widths, destination extent, indicator, radii',
  'Color: primary, highlight, focus, supporting, unavailable, outline',
  'Surface: the primary surface a structure rests on',
  'Typography: label — a structure never speaks with a title voice',
  'Spacing: linked proximity and hierarchical breathing',
];
const List<String> navigationRailDocEngines = [
  'Color, Surface & Spacing Token Engines',
  'Motion Engine — accompany: a structure never announces itself',
  'Accessibility Engine — the opposable reachable target',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Localization & International Engines — the strings and the direction',
];
const List<String> navigationRailDocScans = [
  'No framework rail or drawer in the foundation',
  'No address and no navigator known by a structure',
  'No screen measured and no responsive decision taken by a structure',
  'No coded colour, padding, radius or duration outside the Tokens',
];
const String appBarGalleryTitle =
    'App Bars — Variants (6), States (7) & Scroll declarations (4)';
const String appBarDocHeading = 'MentoraAppBar — official contract';
const List<String> appBarDocArchitecture = [
  'The first Structural Component: it owns the context of a place',
  'It implements PreferredSizeWidget: a host reserves its room',
  'The framework bars stay primitives — none of them is ever used',
  'The reserved room is stable: the context collapses inside it',
  'Its adapter resolves the structure surface only, never a child',
];
const List<String> appBarDocResponsibilities = [
  'It announces where the person is — it is a header, not a layout',
  'It never competes with the content: it names the place, then steps back',
  'A place that cannot be named announces nothing',
  'A context has one start: a way out and an identity never share it',
  'It subscribes to no scroll: the application announces, it expresses',
];
const List<String> appBarDocComponents = [
  'MentoraAvatar — owns the identity',
  'MentoraText — owns the typography',
  'MentoraBadge — owns the states',
  'MentoraButton — owns the acts and the way out',
  'MentoraInput — owns the search entry',
];
const List<String> appBarDocForbidden = [
  'The framework app bars used as a business component',
  'A scroll listened to, an offset measured, a decision taken',
  'A control offered without a name',
  'A coded colour, size, padding or duration',
  'Reading the ambient Theme from a component',
];
const List<String> appBarDocTokens = [
  'App Bar: reserved and collapsed extents, divider, progress, stretch',
  'Color: primary, divider',
  'Surface: the primary surface a context rests on',
  'Typography: title, subtitle and supporting — never the content voice',
  'Spacing: distinct separation and linked proximity',
];
const List<String> appBarDocEngines = [
  'Color, Surface & Spacing Token Engines',
  'Motion Engine — show the continuity, never an entrance',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Accessibility Engine — the font scale, applied once by the app',
  'Localization & International Engines — the strings and the direction',
];
const List<String> appBarDocScans = [
  'No framework app bar of any kind in the foundation',
  'A structure imports only official components',
  'It never builds a word, a pictogram or a style of its own',
  'No coded colour, padding, radius or duration outside the Tokens',
];
const String listTileGalleryTitle =
    'List Tiles — Densities (4), Chromes (4), States (7) & Composition';
const String listTileDocHeading = 'MentoraListTile — official contract';
const String listTileDocComponentsTitle = 'Components composed';
const List<String> listTileDocArchitecture = [
  'The first Composition Component: it composes, it never redefines',
  'Its zones are typed, so authority is guaranteed by the compiler',
  'Density and chrome are orthogonal — an act is what makes it interactive',
  'Its adapter resolves the tile surface only, never a child',
  'Breathing is a spacing relation declined by the density',
];
const List<String> listTileDocResponsibilities = [
  'It presents an entity — a line does not exist',
  'It announces the entity, never its layout: one voice, merged',
  'An entity that cannot be named is not an entity',
  'An entity that invites an act honours the reachable minimum',
  'While an entity is loading, no act is offered twice',
];
const List<String> listTileDocComponents = [
  'MentoraAvatar — owns the identity',
  'MentoraText — owns the typography',
  'MentoraBadge — owns the states',
  'MentoraButton — owns the acts',
];
const List<String> listTileDocForbidden = [
  'The framework list tiles and their checkbox, radio, switch kinds',
  'Any expansion tile',
  'Styling a child component from the tile',
  'A coded colour, size, padding or radius',
  'Reading the ambient Theme from a component',
];
const List<String> listTileDocTokens = [
  'List Tile: minimum extents, breathing factors, radius, divider',
  'Color: highlight, selection, focus, outline, divider, disabled',
  'Typography: body, subtitle, supporting, metadata, caption',
  'Spacing: distinct separation and linked proximity',
];
const List<String> listTileDocEngines = [
  'Color & Spacing Token Engines',
  'Motion Engine — accompany: a tile never announces itself',
  'Accessibility Engine — the opposable reachable target',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Localization & International Engines — the strings and the direction',
];
const List<String> listTileDocScans = [
  'No framework list tile of any kind in the foundation',
  'A composition component imports only official components',
  'It never builds a word, an icon or a style of its own',
  'No coded colour, padding or radius outside the Tokens',
];
const String avatarGalleryTitle =
    'Avatars — Identities (10), Shapes (3), Sizes (6) & States (5)';
const String avatarDocHeading = 'MentoraAvatar — official contract';
const List<String> avatarDocArchitecture = [
  'An avatar is inline: no service, no host, no layer — it is content',
  'The Avatar Tokens Adapter resolves identity and state into roles',
  'A portrait, then initials, then the identity mark — always one of them',
  'The state comes from outside: a controller, or a resting value',
  'A circle is half of itself; a rounded form keeps its softness at any size',
];
const List<String> avatarDocResponsibilities = [
  'It represents an identity — never a decoration or an illustration',
  'The identity survives the absence of an image, and its failure',
  'It announces who, never "image": the name is required',
  'It stays pure: no presence, verification, premium, counter or badge',
  'Decorators are composed around it, never built inside it',
];
const List<String> avatarDocForbidden = [
  'The framework avatar widget or its account headers',
  'Any act, gesture or destination carried by an avatar',
  'Any decorator built inside the component',
  'A coded colour, size, padding or radius',
  'Reading the ambient Theme from a component',
];
const List<String> avatarDocTokens = [
  'Avatar: six extents, mark sizes, radius factor, opacities, border',
  'Color: primary, secondary, aiSuggestion, information, supporting',
  'Color: neutral, unavailable, disabled, outline',
  'Surface: the calm surface that carries an archived identity',
  'Typography: caption to title — the initials grow with the extent',
];
const List<String> avatarDocEngines = [
  'Color, Typography & Surface Token Engines',
  'Motion Engine — accompany: an identity never announces itself',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Accessibility Engine — the font scale, applied once by the app',
  'Localization & International Engines — the strings and the direction',
];
const List<String> avatarDocScans = [
  'No framework avatar or account header in the foundation',
  'No act, gesture or callback inside the avatar',
  'No decorator imported by the avatar',
  'No coded colour, padding or radius outside the Tokens',
];
const String badgeGalleryTitle =
    'Badges — Variants (11), Shapes (6), Sizes (3) & States (6)';
const String badgeDocHeading = 'MentoraBadge — official contract';
const List<String> badgeDocArchitecture = [
  'A badge is inline: no service, no host, no layer — it is content',
  'The Badge Tokens Adapter resolves every variant and state to roles',
  'Its words are MentoraText, in a non-structural role only',
  'The state comes from outside: a controller, or a resting value',
  'A tinted ground is the accent itself, never an invented colour',
];
const List<String> badgeDocResponsibilities = [
  'It affirms a state — it never tells a story',
  'It never asks a decision: it replaces no dialog and no message',
  'It never competes with a title: it completes an information',
  'It is never interactive — a badge one can act on is not a badge',
  'A form without words states its meaning: never colour alone',
];
const List<String> badgeDocForbidden = [
  'Chip, InputChip, ChoiceChip, FilterChip, ActionChip, RawChip',
  'Any act, gesture or destination carried by a badge',
  'A coded colour, size, padding or radius',
  'A structural typography role',
  'Reading the ambient Theme from a component',
];
const List<String> badgeDocTokens = [
  'Badge: heights, paddings, icon and dot sizes, radii, opacities',
  'Color: neutral, information, success, warning, critical, verified',
  'Color: secondary, aiSuggestion, unavailable, disabled, outline',
  'Typography: caption and label — never a title role',
  'Spacing: the linked-proximity relation between mark and words',
];
const List<String> badgeDocEngines = [
  'Color, Typography & Spacing Token Engines',
  'Motion Engine — accompany: a badge never announces itself',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Accessibility Engine — the font scale, applied once by the app',
  'Localization & International Engines — the strings and the direction',
];
const List<String> badgeDocScans = [
  'No Material chip of any kind in the foundation',
  'No act, gesture or callback inside the badge',
  'No coded colour, padding or radius outside the Tokens',
  'No ambient Theme read inside a Core Component',
];
const String snackbarGalleryTitle =
    'Snackbars — Variants (8), States (6), Queue & Replace';
const String snackbarDocHeading = 'MentoraSnackbar — official contract';
const List<String> snackbarDocArchitecture = [
  'No route and no framework messenger: the host renders the layer',
  'Its meaning is the signalement: no veil, no blocking, no layer taken',
  'One message at a time — one message, one idea',
  'The queue machinery is shared with the dialog and the sheet',
  'The reading time is a Token, never a motion duration',
];
const List<String> snackbarDocResponsibilities = [
  'It never asks: it carries no act — what is decided is a dialog',
  'It informs, confirms, reassures, and disappears alone',
  'It never interrupts: no focus trap, no focus taken, no pointer stolen',
  'It never tells a story: a single sentence, refused if it holds two',
  'A message that reports an ongoing state waits for that state to end',
];
const List<String> snackbarDocForbidden = [
  'The framework snackbar, its messenger or its imperative openings',
  'Hiding or removing a message through the framework',
  'A message created outside the official service',
  'A coded color, size, padding or duration',
  'A local animation, or reading the ambient Theme',
];
const List<String> snackbarDocTokens = [
  'Snackbar: dwell times, width, radius, border, icon, entry offset',
  'Color: information, success, warning, critical, unavailable, outline',
  'Surface: the protected surface that carries the message',
  'Elevation: the signalement meaning — never a height',
  'Spacing: distinct separation and linked proximity',
];
const List<String> snackbarDocEngines = [
  'Color, Surface, Spacing & Elevation Token Engines',
  'Motion Engine — reassure, or attract when it must be seen',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Accessibility Engine — the font scale, applied once by the app',
  'Localization & International Engines — the strings and the direction',
];
const List<String> snackbarDocScans = [
  'No Material snackbar and no messenger in the foundation',
  'No message built outside the official service',
  'No coded duration, radius, padding or color',
  'No ambient Theme read inside a Core Component',
];
const String sheetGalleryTitle =
    'Bottom Sheets — Variants (8), States (8), Detents & Service';
const String sheetDocHeading = 'MentoraBottomSheet — official contract';
const List<String> sheetDocArchitecture = [
  'No route, no Navigator: the host renders the layer, always mounted',
  'A sheet never encloses — its meaning is always the aparté',
  'What must be answered is a dialog, never a sheet',
  'The service owns where the sheet rests: expanding is a demand',
  'The queue machinery is shared with the dialog — written once',
];
const List<String> sheetDocResponsibilities = [
  'It never interrupts: it accompanies and extends the screen',
  'It never replaces a page',
  'It never occupies room without a reason — only some may expand',
  'It disappears as soon as its purpose is served',
  'A released gesture settles on a detent, or lets the sheet go',
  'The focus is trapped while it lasts, and restored where it was',
];
const List<String> sheetDocForbidden = [
  'showModalBottomSheet or showBottomSheet anywhere',
  'BottomSheet or ModalBottomSheetRoute in a screen',
  'A sheet created outside the official service',
  'A coded color, size, radius or duration',
  'A local animation, or reading the ambient Theme',
];
const List<String> sheetDocTokens = [
  'BottomSheet: detent fractions, dismiss travel, width, radius, handle',
  'Color: outline, focus, supporting, immersion',
  'Surface: the primary surface — the secondary one for a preview',
  'Elevation: the aparté meaning — never a height',
  'Spacing: focus space, hierarchical breathing, linked proximity',
];
const List<String> sheetDocEngines = [
  'Color, Surface, Spacing & Elevation Token Engines',
  'Motion Engine — accompany, for arriving, settling and leaving',
  'Accessibility Engine — the opposable reachable grip',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Localization & International Engines — the strings and the direction',
];
const List<String> sheetDocScans = [
  'No Material bottom sheet and no imperative opening in the foundation',
  'No layer built outside the official service',
  'No coded duration, radius, padding or color',
  'No ambient Theme read inside a Core Component',
];
const String dialogGalleryTitle =
    'Dialogs — Variants (8), States (8), Service & Queue';
const String dialogDocHeading = 'MentoraDialog — official contract';
const List<String> dialogDocArchitecture = [
  'No route, no showDialog: the host renders the layer above the app',
  'The service holds one exchange at a time — every meaning is exclusive',
  'The elevation MEANING decides: an aparté steps back, a decision answers',
  'The request verifies its contracts at the door of the service',
  'Title, message, consequence and acts are Mentora components',
];
const List<String> dialogDocResponsibilities = [
  'It never surprises: it explains, reassures, protects and confirms',
  'It never forces: a dialog that asks offers at least two ways out',
  'It never manipulates: one recommendation at most, dangers stay explicit',
  'It never hides a consequence: a critical dialog states what it costs',
  'Enter performs the recommendation — never a dangerous act',
  'The focus is trapped while it lasts, and restored where it was',
];
const List<String> dialogDocForbidden = [
  'AlertDialog, Dialog, SimpleDialog in a screen',
  'showDialog or showAdaptiveDialog anywhere',
  'A dialog created outside the official service',
  'A coded color, size, radius or duration',
  'A local animation, or reading the ambient Theme',
];
const List<String> dialogDocTokens = [
  'Dialog: maximum width, radius, border, scrim, icon, entry offset',
  'Color: information, success, warning, critical, attention, immersion',
  'Surface: the protected surface that carries the exchange',
  'Elevation: the aparté and decision meanings — never a height',
  'Spacing: focus space, hierarchical breathing, linked proximity',
];
const List<String> dialogDocEngines = [
  'Color, Surface, Spacing & Elevation Token Engines',
  'Motion Engine — preserve the context, attract when critical',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Accessibility Engine — focus, keyboard and screen readers',
  'Localization & International Engines — the strings and the direction',
];
const List<String> dialogDocScans = [
  'No Material dialog and no showDialog in the foundation',
  'No overlay built outside the official service',
  'No coded duration, radius, padding or color',
  'No ambient Theme read inside a Core Component',
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
