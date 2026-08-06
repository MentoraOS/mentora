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
const String pageScaffoldGalleryTitle =
    'Page Scaffolds — Zones, layers and assemblies';
const String pageScaffoldDocHeading = 'MentoraPageScaffold — official contract';
const List<String> pageScaffoldDocArchitecture = [
  'A page is a context: it gathers, it never decides',
  'Every zone is typed: the authority of each structure is compiled in',
  'It is given a configuration already decided by the application',
  'It places the map where its own presentation says it stands',
  'The temporary layers are composed, and never recreated',
];
const List<String> pageScaffoldDocResponsibilities = [
  'It knows no business: it assembles components, never their content',
  'It knows no platform and takes no responsive decision',
  'It never chooses the way through the context: it is given it',
  'It touches the content in no way — no padding, no scroll, no order',
  'Each zone travels as its own focus group',
];
const List<String> pageScaffoldDocComponents = [
  'MentoraAppBar — owns the place',
  'MentoraNavigationRail & MentoraNavigationDrawer — own the way through',
  'MentoraTabs — owns the facets of the context',
  'MentoraSearchBar — owns the intention of finding',
  'MentoraButton — owns the acts kept at hand',
  'The three official hosts — own the layers that come and go',
];
const List<String> pageScaffoldDocForbidden = [
  'The framework scaffold and every structure it carries',
  'Any business, any platform, any responsive decision',
  'Rebuilding a structure, a layer or a Core Component',
  'Wrapping, padding or reordering the content',
  'A coded colour, size, padding or duration',
];
const List<String> pageScaffoldDocTokens = [
  'Page Scaffold: the lines between zones, and nothing more',
  'Surface: the scene the whole page rests on',
  'Color: the divider role',
  'Spacing: the breathing around the acts a page keeps at hand',
];
const List<String> pageScaffoldDocEngines = [
  'Color, Surface & Spacing Token Engines',
  'Motion Engine — show the continuity: a context does not change',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Accessibility Engine — the font scale, applied once by the app',
  'Localization & International Engines — the strings and the direction',
];
const List<String> pageScaffoldDocScans = [
  'No framework scaffold in the Design Kit',
  'No business, no platform, no navigation decided by a page',
  'No structure or Core Component rebuilt',
  'No coded colour, padding, radius or duration outside the Tokens',
];
const String bottomNavigationGalleryTitle =
    'Bottom Navigations — Destinations (2 to 5), States (5) & Badges';
const String bottomNavigationDocHeading =
    'MentoraBottomNavigation — official contract';
const List<String> bottomNavigationDocArchitecture = [
  'A Structural Component: the principal level, never a menu',
  'A destination is an IDENTITY — never a position, never an index',
  'The application announces where the person is',
  'The structure reports the identity that was asked for',
  'Below two destinations there is no choice; beyond five, no level',
];
const List<String> bottomNavigationDocResponsibilities = [
  'It shows where the person is, and where they may go',
  'It never navigates: no address, no route, no push, no link',
  'It knows no platform and no surface: it is given its configuration',
  'It never takes the focus, and always gives it back',
  'The band is a minimum: when the words grow, it grows with them',
];
const List<String> bottomNavigationDocComponents = [
  'MentoraText — owns the typography of the names',
  'MentoraBadge — owns what is happening in a place',
  'The mark stays a Flutter primitive until the Iconography wave',
];
const List<String> bottomNavigationDocForbidden = [
  'The framework bottom navigations and their destinations',
  'Any address, any navigator, any routing known by the structure',
  'Any knowledge of the platform, and any responsive decision',
  'Rebuilding a badge or a word, and any index of any kind',
  'A coded colour, size, padding or duration',
];
const List<String> bottomNavigationDocTokens = [
  'Bottom Navigation: the band, the mark, the capsule and the line',
  'Color: primary, highlight, focus, supporting, unavailable, divider',
  'Surface: the primary surface the principal level rests on',
  'Typography: label — the principal level never speaks louder',
  'Spacing: the linked proximity around each place',
];
const List<String> bottomNavigationDocEngines = [
  'Color, Surface & Spacing Token Engines',
  'Motion Engine — show the continuity: the place never jumps',
  'Accessibility Engine — the opposable reachable target',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Localization & International Engines — the strings and the direction',
];
const List<String> bottomNavigationDocScans = [
  'No framework bottom navigation anywhere in the foundation',
  'No navigation, no platform, no position known by the structure',
  'No official navigation component left in the application shell',
  'No Core Component rebuilt, and no coded value outside the Tokens',
];
const String narrowAdaptationGalleryTitle =
    'List Tiles — Narrow adaptation (180 to 480 dp)';
const String workspaceGalleryTitle =
    'Workspaces — Channels (4), Surfaces (3) & Layers';
const String workspaceDocHeading = 'MentoraWorkspace — official contract';

/// The words of the catalogue scene. The context composes none of
/// them: the application owns every string it carries.
const String workspaceLabel = 'Contexte de travail';
const String workspacePageLabel = 'Page courante';
const String workspaceHeading = 'Surface de travail';
const String workspaceBody =
    'Le contenu appartient entierement a l application.';
const List<String> workspaceDocArchitecture = [
  'A Structural Component: THE working context, never a page',
  'The surface is SEALED: the compiler admits exactly one of three',
  'The disposition is announced, and disagreement is refused',
  'Where the person is arrives resolved, and every channel is held to it',
  'The layers are composed from the single official order, never restated',
];
const List<String> workspaceDocResponsibilities = [
  'It assembles official components; it owns none of them',
  'It never decides a disposition, a navigation or a surface',
  'It creates no scroll view, and no padding: the surface stays intact',
  'Each zone travels as its own focus group; the focus is never taken',
  'A layer is mounted only when its service is given',
];
const List<String> workspaceDocComponents = [
  'MentoraPageScaffold, MentoraSplitView, MentoraMasterDetail — surfaces',
  'MentoraNavigationDrawer, MentoraNavigationRail, MentoraBottomNavigation',
  'The three official hosts — own the layers that come and go',
];
const List<String> workspaceDocForbidden = [
  'The framework scaffold, drawer, navigation bar, app bar and dialogs',
  'MediaQuery, LayoutBuilder, the Responsive Engine, the platform',
  'Navigator, Route, GoRouter and every address',
  'Any business, any data, any model, any list, any sort, any filter',
  'A Widget? where an official type exists, and any coded value',
];
const List<String> workspaceDocTokens = [
  'Workspace: the room a context adds between its zones — zero, declared',
  'Surface: the scene the whole working context rests on',
];
const List<String> workspaceDocEngines = [
  'Surface Token Engine',
  'Motion Engine — show the continuity: a context does not change',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Localization & International Engines — the strings and the direction',
];
const List<String> workspaceDocScans = [
  'No framework scaffold, drawer, navigation or app bar in the foundation',
  'No navigator, no platform, no measure, no responsive decision',
  'No business, no data, no model named by a working context',
  'No component rebuilt, no ambient theme, no coded value',
  'One MentoraWorkspace exists in the whole product',
];
const String splitViewGalleryTitle =
    'Split Views — Axes (2), Regions by identity & Separations';
const String splitViewDocHeading = 'MentoraSplitView — official contract';

/// The regions of the catalogue scene. The workspace composes none of
/// these words: the application owns every string it carries.
const String splitViewNavigationLabel = 'Region de navigation';
const String splitViewWorkspaceLabel = 'Espace de travail';
const String splitViewInspectorLabel = 'Region de details';
const String splitViewResizeLabel = 'Redimensionner la region';
const String splitViewNavigationHeading = 'Navigation';
const String splitViewWorkspaceHeading = 'Espace de travail';
const String splitViewInspectorHeading = 'Details';
const String splitViewContentBody =
    'Le contenu appartient entierement a l application.';
const String splitViewHideLabel = 'Masquer les details';
const String splitViewShowLabel = 'Montrer les details';
const List<String> splitViewDocArchitecture = [
  'A Structural Component: a shared workspace, never a responsive layout',
  'A region is an IDENTITY — never a position, never an index',
  'The room is announced already decided: a specification, never a ratio',
  'Exactly one region takes what is left, and it is named by identity',
  'Placement only — no flex, no measure, no breakpoint read here',
];
const List<String> splitViewDocResponsibilities = [
  'It expresses a spatial relation; it decides none of it',
  'A separation says that two regions exist, and nothing else',
  'Moving a separation is an intention: it is reported, never performed',
  'A hidden region does not exist: not built, not focusable, not spoken',
  'Each region is a named landmark and its own focus group',
];
const List<String> splitViewDocComponents = [
  'The regions are given whole: the workspace composes neither',
  'MentoraPageScaffold — carries the workspace as its content',
  'MentoraCard, MentoraListTile, MentoraText, MentoraButton — inside them',
];
const List<String> splitViewDocForbidden = [
  'The framework split views, and a Row used to share a room',
  'MediaQuery, LayoutBuilder, the Responsive Engine, the platform',
  'Expanded, Flexible or any flex factor',
  'Any position, any index, any business, any data',
  'A coded colour, size, padding or duration',
];
const List<String> splitViewDocTokens = [
  'Split View: the separation, the room to take hold of, the extent floor',
  'Color: the divider and focus roles',
  'Surface: the primary surface the regions share',
];
const List<String> splitViewDocEngines = [
  'Color & Surface Token Engines',
  'Motion Engine — show the continuity: a workspace never jumps',
  'Accessibility Engine — the opposable reachable target',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Localization & International Engines — the strings and the direction',
];
const List<String> splitViewDocScans = [
  'No framework split view, no screen measured, no platform known',
  'No position: identities travel, ranks do not exist',
  'No business, no data, no selection named by the workspace',
  'No Core Component rebuilt, and no coded value outside the Tokens',
];
const String masterDetailGalleryTitle =
    'Master Details — Presentations (3), Visibility (2) & Regions (2)';
const String masterDetailDocHeading = 'MentoraMasterDetail — official contract';

/// The two spaces of the catalogue scene. The relation composes none
/// of these words: the application owns every string it carries.
const String masterDetailMasterHeading = 'Conversations';
const String masterDetailDetailHeading = 'Awa Mensah';
const String masterDetailDetailBody =
    'Le contenu appartient entierement a l application.';
const String masterDetailDetailAct = 'Repondre';
const String masterDetailMasterLabel = 'Liste des conversations';
const String masterDetailDetailLabel = 'Conversation ouverte';
const String masterDetailRegionToggleLabel = 'Changer de region active';
const List<String> masterDetailDocArchitecture = [
  'A Structural Component: a relation between two spaces, never a layout',
  'The application announces the presentation, the visibility, the region',
  'The room is announced already decided: a specification, never a ratio',
  'Placement only — no flex, no measure, no proportion computed here',
  'A space that is not shown is not built: nothing of it stays reachable',
];
const List<String> masterDetailDocResponsibilities = [
  'One space presents, the other deepens: the relation holds them',
  'It knows no content, no data, no business and no selection',
  'It never decides which space is shown, nor which one is worked in',
  'Each space is a named landmark and its own focus group',
  'Asking a space to step aside is reported, never performed',
];
const List<String> masterDetailDocComponents = [
  'The two spaces are given whole: the relation composes neither',
  'MentoraPageScaffold — carries the relation as its content',
  'MentoraCard, MentoraListTile, MentoraText, MentoraButton — inside them',
];
const List<String> masterDetailDocForbidden = [
  'The framework scaffold, and a Row used as a split view',
  'MediaQuery, LayoutBuilder, the Responsive Engine, the platform',
  'Expanded or Flexible: a relation never decides a proportion',
  'Any selection, any data, any business, any navigation',
  'A coded colour, size, padding or duration',
];
const List<String> masterDetailDocTokens = [
  'Master Detail: the line between two spaces, the veil, the extent floor',
  'Color: the divider and immersion roles',
  'Surface: primary for the space worked in, secondary for the one waiting',
];
const List<String> masterDetailDocEngines = [
  'Color & Surface Token Engines',
  'Motion Engine — show the continuity: a relation never jumps',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Localization & International Engines — the strings and the direction',
];
const List<String> masterDetailDocScans = [
  'No framework scaffold, no MediaQuery, no LayoutBuilder, no responsive',
  'No flex, no proportion, no measure taken by the relation',
  'No business, no data, no selection named by the relation',
  'No Core Component rebuilt, and no coded value outside the Tokens',
];
const String drawerGalleryTitle =
    'Navigation Drawers — Presentations (3), Visibility (2) & States (5)';
const String drawerDocHeading = 'MentoraNavigationDrawer — official contract';
const List<String> drawerDocArchitecture = [
  'A Structural Component: an orientation map, never a menu',
  'A destination is an IDENTITY — never a position, never an address',
  'The application announces the presentation and the visibility',
  'The person space is a MentoraListTile: the entity that owns it',
  'A permanent map lives beside the content; the others pass in front',
];
const List<String> drawerDocResponsibilities = [
  'It says where the person is, and where they may go',
  'It never decides for them: it reports an identity',
  'It never opens and never closes itself: it is told',
  'Asking to be put away is reported — a permanent map never asks',
  'It never takes the focus, and always gives it back',
];
const List<String> drawerDocComponents = [
  'MentoraListTile — presents the space, and owns the entity',
  'MentoraAvatar — owns the identity, inside that tile',
  'MentoraText — owns the typography',
  'MentoraBadge — owns what is happening in a place',
  'MentoraButton — owns the acts',
];
const List<String> drawerDocForbidden = [
  'The framework drawers, their destinations and their controllers',
  'Any address, any navigator, any routing known by the map',
  'Any knowledge of the platform, and any responsive decision',
  'Rebuilding an avatar, a badge, a button, a word or a tile',
  'A coded colour, size, padding or duration',
];
const List<String> drawerDocTokens = [
  'Drawer: presentation specs, scrim, destination extent, radii',
  'Color: primary, highlight, focus, supporting, unavailable, immersion',
  'Surface: the primary surface a map rests on',
  'Typography: label and supporting — a map never speaks louder',
  'Spacing: linked proximity, distinct separation, hierarchical breathing',
];
const List<String> drawerDocEngines = [
  'Color, Surface & Spacing Token Engines',
  'Motion Engine — show the continuity: the space never changes',
  'Accessibility Engine — the opposable reachable target',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Localization & International Engines — the strings and the direction',
];
const List<String> drawerDocScans = [
  'No framework drawer or navigation widget in the foundation',
  'No platform known by a structure',
  'No address, no position, no screen measured',
  'No Core Component rebuilt, and no coded value outside the Tokens',
];
const String searchBarGalleryTitle =
    'Search Bars — Variants (5), States (7), Aids & Prepared acts';
const String searchBarDocHeading = 'MentoraSearchBar — official contract';
const List<String> searchBarDocArchitecture = [
  'A Structural Component: it carries an intention, never a field',
  'The entry is a MentoraInput — it owns the writing and the input method',
  'The controller carries the acknowledged intention, phase and aids',
  'Presentation is a Token spec: extent, radius, ground and delimitation',
  'Voice and history are prepared affordances: named, never performed',
];
const List<String> searchBarDocResponsibilities = [
  'It helps to find — it never finds',
  'It knows a query, and a query is never a result',
  'It never interprets, never normalizes, never matches anything',
  'It never seeks: it reports an intention, the application decides',
  'An aid is never a search and never a way somewhere: it is reported',
];
const List<String> searchBarDocComponents = [
  'MentoraInput — owns the entry, the input method and the composition',
  'MentoraText — owns the typography of the aids',
  'MentoraButton — owns the acts offered beside the intention',
];
const List<String> searchBarDocForbidden = [
  'The framework search widgets, anchors, controllers and delegates',
  'Any interpretation, normalization or matching of a query',
  'Any index, any filter, any network call',
  'Any measure of the screen or responsive decision taken here',
  'A coded colour, size, padding or duration',
];
const List<String> searchBarDocTokens = [
  'Search Bar: presentation specs, icon, aid extent, radii, opacities',
  'Color: primary, critical, supporting, unavailable, highlight, outline',
  'Surface: the calm surface an intention rests on',
  'Typography: body and supporting — an aid never speaks louder',
  'Spacing: linked proximity and distinct separation',
];
const List<String> searchBarDocEngines = [
  'Color, Surface & Spacing Token Engines',
  'Motion Engine — accompany: a bar never hurries anyone',
  'Accessibility Engine — the opposable reachable target',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Localization & International Engines — the strings and the direction',
];
const List<String> searchBarDocScans = [
  'No framework search widget in the foundation',
  'No interpretation, no index, no filter, no network in a structure',
  'No screen measured and no responsive decision taken by a structure',
  'No coded colour, padding, radius or duration outside the Tokens',
];
const String tabsGalleryTitle =
    'Tabs — Emphases (2), Shapes (3), Overflow (2) & States (6)';
const String tabsDocHeading = 'MentoraTabs — official contract';
const List<String> tabsDocArchitecture = [
  'A Structural Component: it organizes the facets of one context',
  'A facet is an IDENTITY — never a position, an address or a page',
  'Selection travels by identity: no position exists in its API',
  'Overflow is declared by the application: the set measures nothing',
  'Emphasis and shape are orthogonal — any shape may be secondary',
];
const List<String> tabsDocResponsibilities = [
  'Changing facet never means leaving the context',
  'It organizes; it never navigates between modules',
  'It never decides what is shown: it reports, the application announces',
  'A single facet reveals nothing: at least two are required',
  'A facet still being prepared is never chosen',
];
const List<String> tabsDocComponents = [
  'MentoraText — owns the typography',
  'MentoraBadge — owns what is happening in a facet',
];
const List<String> tabsDocForbidden = [
  'The framework tab widgets and their controllers',
  'Any address, any page or any position known by the set',
  'Any measure of the screen or responsive decision taken here',
  'An identity or a way out: those belong to the other structures',
  'A coded colour, size, padding or duration',
];
const List<String> tabsDocTokens = [
  'Tabs: facet extent, minimum width, indicator, radii, opacities',
  'Color: primary, secondary, focus, highlight, supporting, unavailable',
  'Surface: the calm surface a segmented set encloses its facets on',
  'Typography: label — a set never speaks with the voice of its content',
  'Spacing: distinct separation and linked proximity',
];
const List<String> tabsDocEngines = [
  'Color, Surface & Spacing Token Engines',
  'Motion Engine — show the continuity: the context never changes',
  'Accessibility Engine — the opposable reachable target',
  'Appearance Engine — theme, contrast, density, reading comfort',
  'Localization & International Engines — the strings and the direction',
];
const List<String> tabsDocScans = [
  'No framework tab widget or controller in the foundation',
  'No position in the public API of a structure',
  'No address and no screen measured by a structure',
  'No coded colour, padding, radius or duration outside the Tokens',
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
