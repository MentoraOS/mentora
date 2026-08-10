import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_announcement.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_destination.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/bottom_sheet/mentora_bottom_sheet_host.dart';
import 'package:mentora/foundation/design_kit/components/bottom_sheet/mentora_bottom_sheet_service.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button_style.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/dialog/mentora_dialog_host.dart';
import 'package:mentora/foundation/design_kit/components/dialog/mentora_dialog_service.dart';
import 'package:mentora/foundation/design_kit/components/snackbar/mentora_snackbar_host.dart';
import 'package:mentora/foundation/design_kit/components/snackbar/mentora_snackbar_service.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/layout/analytics_layout/mentora_analytics_layout.dart';
import 'package:mentora/foundation/design_kit/layout/content_layout/mentora_content_layout.dart';
import 'package:mentora/foundation/design_kit/layout/catalog_layout/mentora_catalog_layout.dart';
import 'package:mentora/foundation/design_kit/layout/dashboard_layout/mentora_dashboard_layout.dart';
import 'package:mentora/foundation/design_kit/layout/detail_layout/mentora_detail_layout.dart';
import 'package:mentora/foundation/design_kit/layout/feed_layout/mentora_feed_layout.dart';
import 'package:mentora/foundation/design_kit/layout/master_detail_layout/mentora_master_detail_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_assembly.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/form_layout/mentora_form_layout.dart';
import 'package:mentora/foundation/design_kit/layout/grid_layout/mentora_grid_layout.dart';
import 'package:mentora/foundation/design_kit/layout/list_layout/mentora_list_layout.dart';
import 'package:mentora/foundation/design_kit/layout/navigation_layout/mentora_navigation_layout.dart';
import 'package:mentora/foundation/design_kit/layout/settings_layout/mentora_settings_layout.dart';
import 'package:mentora/foundation/design_kit/layout/section_layout/mentora_section_layout.dart';
import 'package:mentora/foundation/design_kit/layout/split_workspace_layout/mentora_split_workspace_layout.dart';
import 'package:mentora/foundation/design_kit/layout/tabbed_content_layout/mentora_tabbed_content_layout.dart';
import 'package:mentora/foundation/design_kit/layout/timeline_layout/mentora_timeline_layout.dart';
import 'package:mentora/foundation/design_kit/layout/wizard_layout/mentora_wizard_layout.dart';
import 'package:mentora/foundation/design_kit/layout/workspace_layout/mentora_workspace_layout.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/app_bar/mentora_app_bar.dart';
import 'package:mentora/foundation/design_kit/structure/bottom_navigation/mentora_bottom_navigation.dart';
import 'package:mentora/foundation/design_kit/structure/master_detail/mentora_master_detail.dart';
import 'package:mentora/foundation/design_kit/structure/master_detail/mentora_master_detail_style.dart';
import 'package:mentora/foundation/design_kit/structure/page_scaffold/mentora_page_scaffold.dart';
import 'package:mentora/foundation/design_kit/structure/split_view/mentora_split_view.dart';
import 'package:mentora/foundation/design_kit/structure/split_view/mentora_split_view_style.dart';
import 'package:mentora/foundation/design_kit/structure/tabs/mentora_tabs.dart';
import 'package:mentora/foundation/design_kit/structure/tabs/mentora_tabs_style.dart';
import 'package:mentora/foundation/design_kit/structure/workspace/mentora_workspace.dart';
import 'package:mentora/foundation/design_kit/structure/workspace/mentora_workspace_style.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

const String _home = 'home';

/// The content the application owns — recognisable, and never touched
/// by the layout that carries it.
const Widget _content = MentoraText(
  'Le contenu appartient à l’application.',
  key: Key('layout-surface'),
  role: MentoraTextRole.body,
);

const List<MentoraDestination> _destinations = [
  MentoraDestination(
    id: _home,
    label: 'Accueil',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  MentoraDestination(
    id: 'elsewhere',
    label: 'Ailleurs',
    icon: Icons.explore_outlined,
    selectedIcon: Icons.explore,
  ),
];

MentoraBottomNavigation get _base => MentoraBottomNavigation(
  destinations: _destinations,
  selectedDestinationId: _home,
  semanticLabel: 'Navigation principale',
  onDestinationRequested: (_) {},
);

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

MentoraLayoutContext _frame({
  bool withNavigation = false,
  MentoraDialogService? dialogs,
  MentoraBottomSheetService? sheets,
  MentoraSnackbarService? messages,
  String semanticLabel = 'Contexte de travail',
}) {
  return MentoraLayoutContext(
    semanticLabel: semanticLabel,
    navigation: const MentoraNavigationAnnouncement(destinationId: _home),
    configuration: MentoraWorkspaceConfiguration(
      navigation: withNavigation
          ? MentoraWorkspaceNavigationChannel.base
          : MentoraWorkspaceNavigationChannel.none,
    ),
    base: withNavigation ? _base : null,
    dialogs: dialogs,
    sheets: sheets,
    messages: messages,
  );
}

const List<MentoraSplitRegion> _regions = [
  MentoraSplitRegion(
    id: 'navigation',
    semanticLabel: 'Région de navigation',
    content: _content,
  ),
  MentoraSplitRegion(
    id: 'workspace',
    semanticLabel: 'Espace de travail',
    content: SizedBox.shrink(),
  ),
];

const MentoraSplitLayoutSpecification _specification =
    MentoraSplitLayoutSpecification(
      extents: {'navigation': 240},
      fillsRemainingRegionId: 'workspace',
    );

/// The five official shapes, each built the way a product builds it.
Map<MentoraLayoutKind, Widget> _layouts({
  MentoraLayoutContext? frame,
  MentoraDialogService? dialogs,
  MentoraBottomSheetService? sheets,
  MentoraSnackbarService? messages,
}) {
  final plain =
      frame ?? _frame(dialogs: dialogs, sheets: sheets, messages: messages);
  return {
    MentoraLayoutKind.workspace: MentoraWorkspaceLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      place: const MentoraAppBar(title: 'Page courante'),
      acts: [
        MentoraButton(
          label: 'Confirmer',
          onPressed: () {},
          size: MentoraButtonSize.small,
        ),
      ],
      content: _content,
    ),
    MentoraLayoutKind.dashboard: MentoraDashboardLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      panels: const [
        MentoraDashboardPanel(title: 'Premier sujet', content: _content),
        MentoraDashboardPanel(title: 'Second sujet', content: _content),
      ],
    ),
    MentoraLayoutKind.navigation: MentoraNavigationLayout(
      frame: _frame(
        withNavigation: true,
        dialogs: dialogs,
        sheets: sheets,
        messages: messages,
      ),
      pageSemanticLabel: 'Accueil',
      content: _content,
    ),
    MentoraLayoutKind.splitWorkspace: MentoraSplitWorkspaceLayout(
      frame: plain,
      regions: _regions,
      specification: _specification,
    ),
    MentoraLayoutKind.content: MentoraContentLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      regions: [
        MentoraContentRegion(
          id: 'resume',
          semanticLabel: 'Résumé',
          content: _content,
        ),
      ],
    ),
    MentoraLayoutKind.section: MentoraSectionLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      sections: const [
        MentoraSection(
          id: 'resume',
          title: 'Résumé',
          description: 'Ce qui complète le nom',
          content: _content,
        ),
      ],
    ),
    MentoraLayoutKind.list: MentoraListLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      listId: 'transactions',
      listSemanticLabel: 'Les transactions',
      items: const [MentoraIdentifiedContent(id: 'premier', content: _content)],
    ),
    MentoraLayoutKind.grid: MentoraGridLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      gridId: 'indicateurs',
      gridSemanticLabel: 'Les indicateurs',
      disposition: const MentoraGridDisposition(
        rows: [
          MentoraGridRow(
            id: 'haut',
            cells: [
              MentoraGridCell(id: 'nord', extent: 160, content: _content),
            ],
          ),
        ],
      ),
    ),
    MentoraLayoutKind.tabbedContent: MentoraTabbedContentLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      facets: MentoraTabs(
        controller: MentoraTabsController('operations'),
        // A set of facets reveals another side of the same context:
        // the Tabs refuse a single one, and they are right.
        tabs: const [
          MentoraTab(id: 'operations', label: 'Opérations'),
          MentoraTab(id: 'moyens', label: 'Moyens'),
        ],
        onTabSelected: (_) {},
      ),
      contextId: 'portefeuille',
      contextSemanticLabel: 'Le portefeuille',
      revealedContentId: 'operations',
      contents: const [
        MentoraIdentifiedContent(id: 'operations', content: _content),
        MentoraIdentifiedContent(id: 'moyens', content: SizedBox.shrink()),
      ],
    ),
    MentoraLayoutKind.form: MentoraFormLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      header: const MentoraLayoutZone(
        semanticLabel: 'Ce que vous allez faire',
        content: _content,
      ),
      form: const MentoraLayoutZone(
        semanticLabel: 'Vos informations',
        content: _content,
      ),
    ),
    MentoraLayoutKind.feed: MentoraFeedLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      header: const MentoraLayoutZone(
        semanticLabel: 'Ce que vous allez parcourir',
        content: _content,
      ),
      feed: const MentoraLayoutZone(
        semanticLabel: 'Le flux',
        content: _content,
      ),
    ),
    MentoraLayoutKind.catalog: MentoraCatalogLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      catalogId: 'offre',
      catalogSemanticLabel: 'L offre',
      entries: const [
        MentoraIdentifiedContent(id: 'premier', content: _content),
        MentoraIdentifiedContent(id: 'second', content: SizedBox.shrink()),
      ],
    ),
    MentoraLayoutKind.timeline: MentoraTimelineLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      timelineId: 'parcours',
      timelineSemanticLabel: 'Le parcours',
      moments: const [
        MentoraIdentifiedContent(id: 'premier', content: _content),
        MentoraIdentifiedContent(id: 'second', content: SizedBox.shrink()),
      ],
    ),
    MentoraLayoutKind.analytics: MentoraAnalyticsLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      views: const [
        MentoraContentRegion(
          id: 'revenu',
          semanticLabel: 'Le revenu observe',
          content: _content,
        ),
        MentoraContentRegion(
          id: 'activite',
          semanticLabel: 'L activite observee',
          content: SizedBox.shrink(),
        ),
      ],
    ),
    MentoraLayoutKind.settings: MentoraSettingsLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      categories: const [
        MentoraSettingsCategory(
          id: 'compte',
          semanticLabel: 'Le compte',
          summary: _content,
          options: SizedBox.shrink(),
          unfolded: true,
        ),
        MentoraSettingsCategory(
          id: 'securite',
          semanticLabel: 'La securite',
          summary: SizedBox.shrink(),
          options: SizedBox.shrink(),
          unfolded: false,
        ),
      ],
    ),
    MentoraLayoutKind.wizard: MentoraWizardLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      wizardId: 'travail',
      wizardSemanticLabel: 'Le travail',
      revealedStepId: 'premiere',
      steps: const [
        MentoraIdentifiedContent(id: 'premiere', content: _content),
        MentoraIdentifiedContent(id: 'seconde', content: SizedBox.shrink()),
      ],
    ),
    MentoraLayoutKind.detail: MentoraDetailLayout(
      frame: plain,
      pageSemanticLabel: 'Page courante',
      identity: const MentoraLayoutZone(
        semanticLabel: 'Ce que c’est',
        content: _content,
      ),
      actions: const MentoraLayoutZone(
        semanticLabel: 'Ce que l’on peut faire',
        content: SizedBox.shrink(),
      ),
    ),
    MentoraLayoutKind.masterDetail: MentoraMasterDetailLayout(
      frame: plain,
      master: const SizedBox.shrink(),
      detail: _content,
      specification: const MentoraMasterDetailLayoutSpecification(
        masterExtent: 240,
      ),
      masterSemanticLabel: 'Liste',
      detailSemanticLabel: 'Détail',
    ),
  };
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget layout, {
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
  TextDirection direction = TextDirection.ltr,
}) async {
  final services = await _services();
  await tester.pumpWidget(
    MaterialApp(
      theme: services.get<ThemeEngine>().themeForVariant(variant),
      home: DesignKitScope(
        colors: services.get<ColorTokenEngine>(),
        typography: services.get<TypographyTokenEngine>(),
        spacing: services.get<SpacingTokenEngine>(),
        surfaces: services.get<SurfaceTokenEngine>(),
        elevation: services.get<ElevationTokenEngine<ElevationExpression>>(),
        motion: services.get<MotionEngine>(),
        accessibility: services.get<AccessibilityEngine>(),
        appearance: appearance,
        variant: variant,
        child: Directionality(textDirection: direction, child: layout),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return services;
}

Finder _shape(MentoraLayoutKind kind) => find.byKey(Key('layout-${kind.name}'));

void main() {
  group('The Layout family — five shapes, one assembly', () {
    testWidgets('every official shape is a specialization of the one '
        'foundation', (tester) async {
      for (final entry in _layouts().entries) {
        expect(
          entry.value,
          isA<MentoraLayout>(),
          reason:
              '${entry.key.name} must extend the foundation: it is the '
              'only path from a layout to a screen',
        );
      }
      // The registry is closed, and every shape in it is materialized.
      expect(_layouts().keys.toSet(), MentoraLayoutKind.values.toSet());
    });

    testWidgets('every official shape is assembled in the working '
        'context, and says which shape it is', (tester) async {
      for (final entry in _layouts().entries) {
        await _pump(tester, entry.value);
        expect(tester.takeException(), isNull, reason: entry.key.name);
        // One assembly for the five of them, and one working context.
        expect(find.byType(MentoraLayoutAssembly), findsOneWidget);
        expect(find.byType(MentoraWorkspace), findsOneWidget);
        expect(_shape(entry.key), findsOneWidget);
      }
    });

    testWidgets('every layout composes the official structures, and '
        'builds none of them twice', (tester) async {
      final layouts = _layouts();

      await _pump(tester, layouts[MentoraLayoutKind.workspace]!);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      expect(find.byType(MentoraAppBar), findsOneWidget);
      expect(find.byType(MentoraButton), findsOneWidget);

      await _pump(tester, layouts[MentoraLayoutKind.dashboard]!);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      // The panels are official containers and official words.
      expect(find.byType(MentoraCard), findsNWidgets(2));
      expect(find.text('Premier sujet'), findsOneWidget);
      expect(find.byKey(const Key('dashboard-panels')), findsOneWidget);

      await _pump(tester, layouts[MentoraLayoutKind.navigation]!);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      expect(find.byType(MentoraBottomNavigation), findsOneWidget);

      await _pump(tester, layouts[MentoraLayoutKind.content]!);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      expect(find.byKey(const Key('content-regions')), findsOneWidget);

      await _pump(tester, layouts[MentoraLayoutKind.section]!);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      expect(find.byKey(const Key('section-resume')), findsOneWidget);

      await _pump(tester, layouts[MentoraLayoutKind.list]!);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      expect(find.byKey(const Key('list-transactions')), findsOneWidget);

      await _pump(tester, layouts[MentoraLayoutKind.grid]!);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      expect(find.byKey(const Key('grid-indicateurs')), findsOneWidget);

      await _pump(tester, layouts[MentoraLayoutKind.tabbedContent]!);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      expect(find.byType(MentoraTabs), findsOneWidget);
      expect(find.byKey(const Key('tabbed-portefeuille')), findsOneWidget);

      await _pump(tester, layouts[MentoraLayoutKind.catalog]!);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      expect(find.byKey(const Key('list-offre')), findsOneWidget);
      expect(find.byKey(const Key('list-item-premier')), findsOneWidget);

      await _pump(tester, layouts[MentoraLayoutKind.analytics]!);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      expect(find.byKey(const Key('content-region-revenu')), findsOneWidget);

      await _pump(tester, layouts[MentoraLayoutKind.settings]!);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      expect(find.byKey(const Key('settings-categories')), findsOneWidget);
      expect(find.byKey(const Key('settings-category-compte')), findsOneWidget);

      await _pump(tester, layouts[MentoraLayoutKind.wizard]!);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      expect(find.byKey(const Key('tabbed-travail')), findsOneWidget);
      // A step that is not revealed is not there at all.
      expect(find.byKey(const Key('layout-surface')), findsOneWidget);

      await _pump(tester, layouts[MentoraLayoutKind.form]!);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      expect(find.byKey(const Key('content-region-principal')), findsOneWidget);

      await _pump(tester, layouts[MentoraLayoutKind.splitWorkspace]!);
      expect(find.byType(MentoraSplitView), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsNothing);

      await _pump(tester, layouts[MentoraLayoutKind.masterDetail]!);
      expect(find.byType(MentoraMasterDetail), findsOneWidget);
      expect(find.byType(MentoraSplitView), findsNothing);
    });

    testWidgets('the content is handed on untouched: a layout adds no '
        'room of its own around it', (tester) async {
      await _pump(
        tester,
        MentoraNavigationLayout(
          frame: _frame(withNavigation: true),
          pageSemanticLabel: 'Accueil',
          content: _content,
        ),
      );

      // The place carries the content and nothing else, so the content
      // starts exactly where the page starts.
      expect(
        tester.getTopLeft(find.byKey(const Key('layout-surface'))),
        tester.getTopLeft(find.byType(MentoraPageScaffold)),
        reason: 'a layout adds nothing around what it was handed',
      );
    });

    testWidgets('the layers are mounted only when their service is '
        'given', (tester) async {
      await _pump(tester, _layouts()[MentoraLayoutKind.workspace]!);
      expect(find.byType(MentoraDialogHost), findsNothing);
      expect(find.byType(MentoraBottomSheetHost), findsNothing);
      expect(find.byType(MentoraSnackbarHost), findsNothing);

      final services = await _services();
      final withLayers = _layouts(
        dialogs: services.get<MentoraDialogService>(),
        sheets: services.get<MentoraBottomSheetService>(),
        messages: services.get<MentoraSnackbarService>(),
      );
      for (final entry in withLayers.entries) {
        await _pump(tester, entry.value);
        expect(
          find.byType(MentoraDialogHost),
          findsOneWidget,
          reason: entry.key.name,
        );
        expect(
          find.byType(MentoraBottomSheetHost),
          findsOneWidget,
          reason: entry.key.name,
        );
        expect(
          find.byType(MentoraSnackbarHost),
          findsOneWidget,
          reason: entry.key.name,
        );
      }
    });

    testWidgets('a layout decides nothing: what it was handed is what it '
        'expresses', (tester) async {
      await _pump(tester, _layouts()[MentoraLayoutKind.splitWorkspace]!);

      final shared = tester.widget<MentoraSplitView>(
        find.byType(MentoraSplitView),
      );
      expect(shared.layout, same(_specification));
      expect(shared.regions, same(_regions));

      await _pump(tester, _layouts()[MentoraLayoutKind.masterDetail]!);
      final relation = tester.widget<MentoraMasterDetail>(
        find.byType(MentoraMasterDetail),
      );
      expect(relation.presentation, MentoraMasterDetailPresentation.split);
      expect(relation.visibility, MentoraMasterPaneVisibility.shown);
    });

    testWidgets('every layout is a landmark, and every zone travels as '
        'its own focus group', (tester) async {
      final handle = tester.ensureSemantics();
      for (final entry in _layouts().entries) {
        await _pump(tester, entry.value);
        expect(
          tester.getSemantics(find.byType(MentoraWorkspace)).label,
          contains('Contexte de travail'),
          reason: entry.key.name,
        );
        expect(
          find.descendant(
            of: find.byType(MentoraWorkspace),
            matching: find.byType(FocusTraversalGroup),
          ),
          findsWidgets,
          reason: entry.key.name,
        );
      }
      handle.dispose();
    });

    testWidgets('a layout without a contract refuses to build — fail '
        'closed', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // A page announces the context it gathers.
      await refuses(
        MentoraWorkspaceLayout(
          frame: _frame(),
          pageSemanticLabel: '',
          content: _content,
        ),
      );
      await refuses(
        MentoraNavigationLayout(
          frame: _frame(withNavigation: true),
          pageSemanticLabel: '',
          content: _content,
        ),
      );
      // A navigation layout without a way through the product is not
      // a navigation layout.
      await refuses(
        MentoraNavigationLayout(
          frame: _frame(),
          pageSemanticLabel: 'Accueil',
          content: _content,
        ),
      );
      // A dashboard shows subjects, and a panel has one.
      await refuses(
        MentoraDashboardLayout(
          frame: _frame(),
          pageSemanticLabel: 'Page courante',
          panels: const [],
        ),
      );
      await refuses(
        MentoraDashboardLayout(
          frame: _frame(),
          pageSemanticLabel: 'Page courante',
          panels: const [MentoraDashboardPanel(title: '', content: _content)],
        ),
      );
      // The context itself is never unnamed.
      await refuses(
        MentoraWorkspaceLayout(
          frame: _frame(semanticLabel: ''),
          pageSemanticLabel: 'Page courante',
          content: _content,
        ),
      );
    });

    testWidgets('every shape holds in the four themes, both reading '
        'directions and every reading comfort', (tester) async {
      for (final entry in _layouts().entries) {
        for (final variant in ThemeVariantId.values) {
          await _pump(tester, entry.value, variant: variant);
          expect(tester.takeException(), isNull, reason: entry.key.name);
        }
        for (final direction in TextDirection.values) {
          await _pump(tester, entry.value, direction: direction);
          expect(tester.takeException(), isNull, reason: entry.key.name);
        }
        for (final comfort in ReadingComfortPreference.values) {
          await _pump(
            tester,
            entry.value,
            appearance: AppearanceState(readingComfort: comfort),
          );
          expect(tester.takeException(), isNull, reason: entry.key.name);
        }
        for (final scale in FontScalePreference.values) {
          await _pump(
            tester,
            entry.value,
            appearance: AppearanceState(fontScale: scale),
          );
          expect(tester.takeException(), isNull, reason: entry.key.name);
        }
      }
    });

    testWidgets('every transition still comes from the Motion Engine: '
        'None silences it', (tester) async {
      for (final entry in _layouts().entries) {
        await _pump(
          tester,
          entry.value,
          appearance: const AppearanceState(motion: MotionPreference.none),
        );
        expect(
          tester
              .widget<AnimatedContainer>(
                find.byKey(const Key('workspace-surface')),
              )
              .duration,
          Duration.zero,
          reason: entry.key.name,
        );
      }
    });

    testWidgets('outside the Design Kit every layout refuses to build — '
        'fail closed', (tester) async {
      for (final entry in _layouts().entries) {
        await tester.pumpWidget(MaterialApp(home: entry.value));
        expect(tester.takeException(), isStateError, reason: entry.key.name);
      }
    });
  });

  group('Governance — the executable scans ship with the family', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    Iterable<File> layoutFiles() =>
        dartFilesOf('lib/foundation/design_kit/layout');

    /// What a file COMMITS.
    ///
    /// A scan opposes code, and a comment is not code: documenting a
    /// prohibition has never been committing it. The rules below keep
    /// every word they forbid — they simply stop reading the prose
    /// that names them.
    String codeOf(File file) => file
        .readAsLinesSync()
        .map((line) {
          final comment = line.indexOf('//');
          return comment == -1 ? line : line.substring(0, comment);
        })
        .join('\n');

    test('a layout builds no framework widget of its own', () {
      final forbidden = <String, RegExp>{
        'Scaffold': RegExp(r'(?<![A-Za-z])Scaffold\('),
        'AppBar': RegExp(r'(?<![A-Za-z])AppBar\('),
        'Drawer': RegExp(r'(?<![A-Za-z])Drawer\('),
        'NavigationBar': RegExp(r'(?<![A-Za-z])NavigationBar(?![A-Za-z])'),
        'BottomNavigationBar': RegExp(
          r'(?<![A-Za-z])BottomNavigationBar(?![A-Za-z])',
        ),
        'TabBar': RegExp(r'(?<![A-Za-z])TabBar(?![A-Za-z])'),
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
        'a flexible space': RegExp(
          r'(?<![A-Za-z])(Expanded|Flexible|Spacer)(?![A-Za-z])',
        ),
        'a padding of its own': RegExp(r'(?<![A-Za-z])Padding\('),
      };
      final files = layoutFiles();
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = codeOf(file);
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a layout composes official components — '
                'it never builds ${entry.key}',
          );
        }
      }
    });

    test('a layout measures no screen, knows no platform and no '
        'address', () {
      final forbidden = <String, RegExp>{
        'a measure of the screen': RegExp(
          r'(?<![A-Za-z])(MediaQuery|LayoutBuilder|ResponsiveEngine|'
          r'Breakpoint\w*|OrientationBuilder)(?![A-Za-z])',
        ),
        'a platform': RegExp(
          r'(?<![A-Za-z])(Platform|TargetPlatform|defaultTargetPlatform|'
          r'kIsWeb|isAndroid|isIOS)(?![A-Za-z])',
        ),
        'an address': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|routeName|pushNamed|'
          r'MaterialPageRoute)(?![A-Za-z])',
        ),
        'a route type': RegExp(r'(?<![A-Za-z])Route<'),
      };
      for (final file in layoutFiles()) {
        final source = codeOf(file);
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a layout never carries ${entry.key} — the '
                'application decides, the layout composes',
          );
        }
      }
    });

    test('a layout knows no business, no data and no untyped zone', () {
      final forbidden = <String, RegExp>{
        'a business domain': RegExp(
          r'(?<![A-Za-z])(Wallet|Orders?|Marketplace|Business|Inventory|'
          r'Payments?|Messages?|Consultation|Profile|Analytics|Settings|'
          r'Invoice|Facture|Product|Chat)(?![a-z])',
        ),
        'a model or a collection': RegExp(
          r'(?<![A-Za-z])(fromJson|toJson|Model|Repository|Entity|'
          r'HttpClient|Firestore)(?![A-Za-z])',
        ),
        'a selection of data': RegExp(
          r'\.(where|firstWhere|lastWhere|singleWhere|sort|reduce|fold)\(',
        ),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped zone': RegExp(r'final\s+Widget\?\s'),
      };
      for (final file in layoutFiles()) {
        final source = codeOf(file);
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: a layout never carries ${entry.key}',
          );
        }
      }
    });

    test('a layout reads no ambient theme and codes no value', () {
      final forbidden = <String, RegExp>{
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'a coded padding': RegExp(r'EdgeInsets\.\w+\(\s*[0-9]'),
        'a coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'a coded extent': RegExp(r'(width|height|spacing|runSpacing):\s*[1-9]'),
        'a coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
        'a coded opacity': RegExp(r'opacity:\s*[0-9]'),
      };
      for (final file in layoutFiles()) {
        final source = codeOf(file);
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: a layout never carries ${entry.key}',
          );
        }
      }
    });

    test('the layer is assembled in exactly one place: no layout ever '
        'assembles, mounts a layer, or builds a context or a page', () {
      // No layout mounts a layer at all: the working context composes
      // them from the single official order, and the layer above it
      // never touches one.
      final mounts = RegExp(
        r'(MentoraDialogHost\(|MentoraBottomSheetHost\(|'
        r'MentoraSnackbarHost\(|mountOfficialLayers\()',
      );
      for (final file in layoutFiles()) {
        expect(
          mounts.hasMatch(codeOf(file)),
          isFalse,
          reason: '${file.path}: a layout never mounts a layer itself',
        );
      }

      final built = <String, RegExp>{
        'a working context': RegExp(r'MentoraWorkspace\('),
        'a page': RegExp(r'MentoraPageScaffold\('),
      };
      for (final entry in built.entries) {
        final places = <String>[];
        for (final file in layoutFiles()) {
          if (entry.value.hasMatch(codeOf(file))) {
            places.add(file.path.replaceAll(r'\', '/'));
          }
        }
        expect(
          places,
          hasLength(1),
          reason: '${entry.key} is built in exactly one place',
        );
        expect(
          places.single,
          contains('layout/foundation/mentora_layout_assembly.dart'),
          reason: '${entry.key} belongs to the assembly, and to it alone',
        );
      }
    });

    test('a specialization never builds: the foundation is the only '
        'path from a layout to a screen', () {
      for (final file in layoutFiles()) {
        final normalized = file.path.replaceAll(r'\', '/');
        if (normalized.contains('layout/foundation/')) continue;
        final source = codeOf(file);
        expect(
          RegExp(r'Widget\s+build\(').hasMatch(source),
          isFalse,
          reason:
              '$normalized: a specialization declares its kind, its '
              'context and the surface it asks for — never a build',
        );
      }

      // Every layout reaches the one foundation, and the chain is
      // WALKED rather than named: a foundation may grow another link
      // without the rule being rewritten, and no link may be missing.
      final parents = <String, String>{};
      for (final file in layoutFiles()) {
        for (final match in RegExp(
          r'class\s+(Mentora\w+)(?:<[^>]*>)?\s+extends\s+(Mentora\w+)',
        ).allMatches(codeOf(file))) {
          parents[match.group(1)!] = match.group(2)!;
        }
      }
      for (final file in layoutFiles()) {
        final normalized = file.path.replaceAll(r'\', '/');
        if (normalized.contains('layout/foundation/')) continue;
        final shape = RegExp(
          r'class\s+(Mentora\w+Layout)(?![A-Za-z])',
        ).firstMatch(codeOf(file))!.group(1)!;

        final chain = <String>[shape];
        var current = shape;
        while (parents[current] != null && chain.length < 8) {
          current = parents[current]!;
          chain.add(current);
        }
        expect(
          chain.last,
          'MentoraLayout',
          reason:
              '$normalized: $shape reaches the one foundation through '
              '${chain.join(' > ')} — every link is a layout of the '
              'foundation, and none of them builds',
        );
        for (final link in chain.skip(1)) {
          final declaration = layoutFiles().singleWhere(
            (file) =>
                RegExp('class\\s+$link(?![A-Za-z])').hasMatch(codeOf(file)),
          );
          expect(
            declaration.path.replaceAll(r'\', '/'),
            contains('layout/foundation/'),
            reason: '$link: a link of the chain belongs to the foundation',
          );
          // Exactly one link builds, and it is the last one: the
          // foundation. Everything between a shape and it describes.
          expect(
            RegExp(r'Widget\s+build\(').hasMatch(codeOf(declaration)),
            link == 'MentoraLayout',
            reason:
                '$link: the one foundation is the only link that builds '
                '— every link above it only describes',
          );
        }
      }
    });

    test('the foundation depends on no particular layout', () {
      final specialization = RegExp(r"import '[.][.]/\w+_layout/");
      for (final file in dartFilesOf(
        'lib/foundation/design_kit/layout/foundation',
      )) {
        expect(
          specialization.hasMatch(codeOf(file)),
          isFalse,
          reason:
              '${file.path}: the foundation carries the contracts, the '
              'abstractions and the assembly — never a specialization',
        );
      }
    });

    test('the layer has exactly one contract, one style, one theme, one '
        'registry and one assembly', () {
      const singletons = {
        'MentoraLayoutAssembly': 'mentora_layout_assembly.dart',
        'MentoraLayoutContext': 'mentora_layout_context.dart',
        'MentoraLayoutTheme': 'mentora_layout_theme.dart',
        'MentoraLayout': 'mentora_layout.dart',
        'MentoraPageLikeLayout': 'mentora_page_like_layout.dart',
        'MentoraZonedLayout': 'mentora_zoned_layout.dart',
        'MentoraRevealedLayout': 'mentora_revealed_layout.dart',
        'MentoraRegionedLayout': 'mentora_regioned_layout.dart',
        'MentoraCollectedLayout': 'mentora_collected_layout.dart',
        'MentoraPrincipalLayout': 'mentora_principal_layout.dart',
      };
      for (final entry in singletons.entries) {
        final declarations = <String>[];
        for (final file in dartFilesOf('lib')) {
          if (RegExp(
            'class\\s+${entry.key}(?![A-Za-z])',
          ).hasMatch(codeOf(file))) {
            declarations.add(file.path.replaceAll(r'\', '/'));
          }
        }
        expect(declarations, hasLength(1), reason: entry.key);
        expect(
          declarations.single,
          endsWith('layout/foundation/${entry.value}'),
          reason: entry.key,
        );
      }

      // One registry, and no second one may be opened anywhere.
      final registries = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'enum\s+\w*LayoutKind(?![A-Za-z])',
        ).hasMatch(codeOf(file))) {
          registries.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(registries, hasLength(1));
      expect(
        registries.single,
        endsWith('layout/foundation/mentora_layout_kind.dart'),
      );

      // One style file for the layer, and no local one beside a layout.
      final styles = <String>[];
      for (final file in layoutFiles()) {
        if (file.path.endsWith('_style.dart')) {
          styles.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(styles, hasLength(1));
      expect(
        styles.single,
        endsWith('layout/foundation/mentora_layout_style.dart'),
      );
    });

    test('every materialized value lives in the tokens layer: no local '
        'tokens file exists anywhere', () {
      for (final file in dartFilesOf('lib/foundation')) {
        final normalized = file.path.replaceAll(r'\', '/');
        if (!normalized.endsWith('_tokens.dart')) continue;
        expect(
          normalized.contains('design_kit/tokens/'),
          isTrue,
          reason:
              '$normalized: the Universal Token Registry is one layer — '
              'a tokens file never lives beside what consumes it',
        );
      }
      // The whole Layout layer shares that one file.
      expect(
        File(
          'lib/foundation/design_kit/tokens/layout_tokens.dart',
        ).existsSync(),
        isTrue,
      );
    });

    test('each official shape exists exactly once in the product', () {
      const shapes = [
        'MentoraWorkspaceLayout',
        'MentoraDashboardLayout',
        'MentoraNavigationLayout',
        'MentoraSplitWorkspaceLayout',
        'MentoraMasterDetailLayout',
        'MentoraContentLayout',
        'MentoraSectionLayout',
        'MentoraListLayout',
        'MentoraGridLayout',
        'MentoraTabbedContentLayout',
        'MentoraFormLayout',
        'MentoraDetailLayout',
        'MentoraFeedLayout',
        'MentoraWizardLayout',
        'MentoraSettingsLayout',
        'MentoraAnalyticsLayout',
        'MentoraCatalogLayout',
        'MentoraTimelineLayout',
      ];
      for (final shape in shapes) {
        final declarations = <String>[];
        for (final file in dartFilesOf('lib')) {
          if (RegExp('class\\s+$shape(?![A-Za-z])').hasMatch(codeOf(file))) {
            declarations.add(file.path.replaceAll(r'\', '/'));
          }
        }
        expect(declarations, hasLength(1), reason: shape);
        expect(declarations.single, contains('design_kit/layout/'));
      }
      // The vocabulary is closed: five shapes, and no sixth.
      expect(MentoraLayoutKind.values, hasLength(shapes.length));
    });
  });
}
