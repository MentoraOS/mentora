import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_destination.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/bottom_sheet/mentora_bottom_sheet_host.dart';
import 'package:mentora/foundation/design_kit/components/bottom_sheet/mentora_bottom_sheet_service.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/dialog/mentora_dialog_host.dart';
import 'package:mentora/foundation/design_kit/components/dialog/mentora_dialog_service.dart';
import 'package:mentora/foundation/design_kit/components/snackbar/mentora_snackbar_host.dart';
import 'package:mentora/foundation/design_kit/components/snackbar/mentora_snackbar_service.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/bottom_navigation/mentora_bottom_navigation.dart';
import 'package:mentora/foundation/design_kit/structure/master_detail/mentora_master_detail.dart';
import 'package:mentora/foundation/design_kit/structure/master_detail/mentora_master_detail_style.dart';
import 'package:mentora/foundation/design_kit/structure/navigation_drawer/mentora_navigation_drawer.dart';
import 'package:mentora/foundation/design_kit/structure/navigation_drawer/mentora_navigation_drawer_style.dart';
import 'package:mentora/foundation/design_kit/structure/navigation_rail/mentora_navigation_rail.dart';
import 'package:mentora/foundation/design_kit/structure/navigation_rail/mentora_navigation_rail_style.dart';
import 'package:mentora/foundation/design_kit/structure/page_scaffold/mentora_page_scaffold.dart';
import 'package:mentora/foundation/design_kit/structure/split_view/mentora_split_view.dart';
import 'package:mentora/foundation/design_kit/structure/split_view/mentora_split_view_style.dart';
import 'package:mentora/foundation/design_kit/structure/workspace/mentora_workspace.dart';
import 'package:mentora/foundation/design_kit/structure/workspace/mentora_workspace_style.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/workspace_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

const String _home = 'home';

/// The surface the application owns — recognisable, and never touched
/// by the context that carries it.
const Widget _content = MentoraText(
  'Le contenu appartient à l’application.',
  key: Key('workspace-content'),
  role: MentoraTextRole.body,
);

MentoraPageScaffold get _page => const MentoraPageScaffold(
  semanticLabel: 'Page courante',
  content: _content,
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

const List<MentoraDestination> _places = [
  MentoraDestination(
    id: _home,
    label: 'Accueil',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
];

const List<MentoraDrawerSection> _sections = [
  MentoraDrawerSection(
    destinations: [
      MentoraDestination(
        id: _home,
        label: 'Accueil',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
    ],
  ),
];

MentoraBottomNavigation _base({String selected = _home}) =>
    MentoraBottomNavigation(
      destinations: _destinations,
      selectedDestinationId: selected,
      semanticLabel: 'Navigation principale',
      onDestinationRequested: (_) {},
    );

MentoraNavigationRail _rail({String? selected = _home}) =>
    MentoraNavigationRail(
      destinations: _places,
      controller: selected == null
          ? null
          : MentoraNavigationRailController(selected),
      onDestinationSelected: (_) {},
    );

MentoraNavigationDrawer _orientation({
  String selected = _home,
  MentoraDrawerPresentation presentation = MentoraDrawerPresentation.permanent,
}) => MentoraNavigationDrawer(
  presentation: presentation,
  controller: MentoraNavigationDrawerController(
    selectedId: selected,
    visibility: MentoraDrawerVisibility.opened,
  ),
  sections: _sections,
  semanticLabel: 'Espace de la personne',
  onDestinationSelected: (_) {},
);

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

MentoraWorkspace _workspace({
  MentoraWorkspaceSurface? surface,
  MentoraWorkspaceNavigationChannel channel =
      MentoraWorkspaceNavigationChannel.none,
  String destinationId = _home,
  String semanticLabel = 'Contexte de travail',
  MentoraNavigationDrawer? orientation,
  MentoraNavigationRail? rail,
  MentoraBottomNavigation? base,
  MentoraDialogService? dialogs,
  MentoraBottomSheetService? sheets,
  MentoraSnackbarService? messages,
}) {
  return MentoraWorkspace(
    semanticLabel: semanticLabel,
    configuration: MentoraWorkspaceConfiguration(navigation: channel),
    navigation: MentoraWorkspaceNavigationState(destinationId: destinationId),
    orientation: orientation,
    rail: rail,
    base: base,
    dialogs: dialogs,
    sheets: sheets,
    messages: messages,
    surface: surface ?? MentoraWorkspaceSurface.page(_page),
  );
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget workspace, {
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
        child: Directionality(textDirection: direction, child: workspace),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return services;
}

void main() {
  group('MentoraWorkspace — the working context of the product', () {
    testWidgets('a working context assembles the official components, '
        'and each of them stays itself', (tester) async {
      final services = await _services();
      await _pump(
        tester,
        _workspace(
          channel: MentoraWorkspaceNavigationChannel.orientation,
          orientation: _orientation(),
          dialogs: services.get<MentoraDialogService>(),
          sheets: services.get<MentoraBottomSheetService>(),
          messages: services.get<MentoraSnackbarService>(),
        ),
      );

      expect(find.byType(MentoraNavigationDrawer), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      expect(find.byKey(const Key('workspace-content')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the surface is sealed: each official surface is carried '
        'whole, and exactly one at a time', (tester) async {
      await _pump(tester, _workspace());
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      expect(find.byType(MentoraSplitView), findsNothing);

      await _pump(
        tester,
        _workspace(
          surface: MentoraWorkspaceSurface.shared(
            MentoraSplitView(
              regions: [
                MentoraSplitRegion(
                  id: 'navigation',
                  semanticLabel: 'Région de navigation',
                  content: _content,
                ),
                const MentoraSplitRegion(
                  id: 'workspace',
                  semanticLabel: 'Espace de travail',
                  content: SizedBox.shrink(),
                ),
              ],
              layout: const MentoraSplitLayoutSpecification(
                extents: {'navigation': 240},
                fillsRemainingRegionId: 'workspace',
              ),
            ),
          ),
        ),
      );
      expect(find.byType(MentoraSplitView), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsNothing);

      await _pump(
        tester,
        _workspace(
          surface: MentoraWorkspaceSurface.relation(
            const MentoraMasterDetail(
              master: SizedBox.shrink(),
              detail: _content,
              layout: MentoraMasterDetailLayoutSpecification(masterExtent: 240),
              masterSemanticLabel: 'Liste',
              detailSemanticLabel: 'Détail',
            ),
          ),
        ),
      );
      expect(find.byType(MentoraMasterDetail), findsOneWidget);
      expect(find.byType(MentoraSplitView), findsNothing);
    });

    testWidgets('the surface is handed on untouched: a bare context adds '
        'nothing around it', (tester) async {
      await _pump(tester, _workspace());

      expect(
        tester.getTopLeft(find.byType(MentoraPageScaffold)),
        tester.getTopLeft(find.byType(MentoraWorkspace)),
        reason: 'a working context adds nothing around its surface',
      );
      expect(
        tester.getSize(find.byType(MentoraPageScaffold)),
        tester.getSize(find.byType(MentoraWorkspace)),
      );
      // A context adds no room between the things it assembles, and
      // the absence is a declared value.
      expect(workspaceZoneGap, 0);
    });

    testWidgets('a context creates no scroll view of its own', (tester) async {
      await _pump(tester, _workspace());

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('every zone is placed where the disposition announced '
        'says it stands', (tester) async {
      // The principal level closes the context at its base, across the
      // whole width.
      await _pump(
        tester,
        _workspace(
          channel: MentoraWorkspaceNavigationChannel.base,
          base: _base(),
        ),
      );
      final workspace = tester.getRect(find.byType(MentoraWorkspace));
      final level = tester.getRect(find.byType(MentoraBottomNavigation));
      expect(level.bottom, workspace.bottom);
      expect(level.width, workspace.width);
      expect(
        tester.getRect(find.byType(MentoraPageScaffold)).bottom,
        lessThanOrEqualTo(level.top),
      );

      // A rail stands beside the surface, and takes its own room.
      await _pump(
        tester,
        _workspace(
          channel: MentoraWorkspaceNavigationChannel.rail,
          rail: _rail(),
        ),
      );
      final railRect = tester.getRect(find.byType(MentoraNavigationRail));
      expect(railRect.left, tester.getRect(find.byType(MentoraWorkspace)).left);
      expect(
        tester.getRect(find.byType(MentoraPageScaffold)).left,
        railRect.right,
      );

      // A map that passes in front takes no room from the surface.
      await _pump(
        tester,
        _workspace(
          channel: MentoraWorkspaceNavigationChannel.orientation,
          orientation: _orientation(
            presentation: MentoraDrawerPresentation.modal,
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(MentoraPageScaffold)),
        tester.getSize(find.byType(MentoraWorkspace)),
      );
    });

    testWidgets('the layers are mounted only when their service is '
        'given', (tester) async {
      await _pump(tester, _workspace());
      expect(find.byType(MentoraDialogHost), findsNothing);
      expect(find.byType(MentoraBottomSheetHost), findsNothing);
      expect(find.byType(MentoraSnackbarHost), findsNothing);

      final services = await _services();
      await _pump(
        tester,
        _workspace(messages: services.get<MentoraSnackbarService>()),
      );
      expect(find.byType(MentoraSnackbarHost), findsOneWidget);
      expect(find.byType(MentoraDialogHost), findsNothing);
      expect(find.byType(MentoraBottomSheetHost), findsNothing);

      await _pump(
        tester,
        _workspace(
          dialogs: services.get<MentoraDialogService>(),
          sheets: services.get<MentoraBottomSheetService>(),
          messages: services.get<MentoraSnackbarService>(),
        ),
      );
      expect(find.byType(MentoraDialogHost), findsOneWidget);
      expect(find.byType(MentoraBottomSheetHost), findsOneWidget);
      expect(find.byType(MentoraSnackbarHost), findsOneWidget);
    });

    testWidgets('where the person is arrives resolved, and every channel '
        'is held to that one truth', (tester) async {
      for (final entry in {
        MentoraWorkspaceNavigationChannel.base: _workspace(
          channel: MentoraWorkspaceNavigationChannel.base,
          base: _base(),
        ),
        MentoraWorkspaceNavigationChannel.rail: _workspace(
          channel: MentoraWorkspaceNavigationChannel.rail,
          rail: _rail(),
        ),
        MentoraWorkspaceNavigationChannel.orientation: _workspace(
          channel: MentoraWorkspaceNavigationChannel.orientation,
          orientation: _orientation(),
        ),
      }.entries) {
        await _pump(tester, entry.value);
        expect(
          tester.takeException(),
          isNull,
          reason: 'the ${entry.key.name} channel agrees with the context',
        );
      }
    });

    testWidgets('a context refuses to hold two truths about where the '
        'person is — fail closed', (tester) async {
      Future<void> refuses(MentoraWorkspace workspace) async {
        await _pump(tester, workspace);
        expect(tester.takeException(), isStateError);
      }

      // A channel that disagrees with the resolved state.
      await refuses(
        _workspace(
          channel: MentoraWorkspaceNavigationChannel.base,
          base: _base(selected: 'elsewhere'),
        ),
      );
      // A channel that says nothing at all.
      await refuses(
        _workspace(
          channel: MentoraWorkspaceNavigationChannel.rail,
          rail: _rail(selected: null),
        ),
      );
      // A disposition announced that is not the one given.
      await refuses(
        _workspace(channel: MentoraWorkspaceNavigationChannel.base),
      );
      await refuses(
        _workspace(
          channel: MentoraWorkspaceNavigationChannel.rail,
          base: _base(),
        ),
      );
      await refuses(
        _workspace(
          channel: MentoraWorkspaceNavigationChannel.none,
          base: _base(),
        ),
      );
      // A context without a name, and a state that resolves nothing.
      await refuses(_workspace(semanticLabel: ''));
      await refuses(_workspace(destinationId: ''));
    });

    testWidgets('the context is a landmark, and each zone travels as its '
        'own focus group', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        _workspace(
          channel: MentoraWorkspaceNavigationChannel.base,
          base: _base(),
        ),
      );

      expect(
        tester.getSemantics(find.byType(MentoraWorkspace)).label,
        contains('Contexte de travail'),
      );
      // One group for the surface, one for the principal level — and
      // the surface keeps the groups of its own zones, untouched.
      final all = tester.widgetList(
        find.descendant(
          of: find.byType(MentoraWorkspace),
          matching: find.byType(FocusTraversalGroup),
        ),
      );
      final insideTheSurface = tester.widgetList(
        find.descendant(
          of: find.byType(MentoraPageScaffold),
          matching: find.byType(FocusTraversalGroup),
        ),
      );
      expect(all.length - insideTheSurface.length, 2);
      handle.dispose();
    });

    testWidgets('the focus stays where the person left it: a context '
        'never takes it', (tester) async {
      final inside = FocusNode(debugLabel: 'surface');
      addTearDown(inside.dispose);

      await _pump(
        tester,
        _workspace(
          surface: MentoraWorkspaceSurface.page(
            MentoraPageScaffold(
              semanticLabel: 'Page courante',
              content: Focus(focusNode: inside, child: _content),
            ),
          ),
        ),
      );

      inside.requestFocus();
      await tester.pumpAndSettle();
      expect(inside.hasPrimaryFocus, isTrue);

      await tester.pumpAndSettle();
      expect(inside.hasPrimaryFocus, isTrue);
    });

    testWidgets('the context holds in the four themes, both reading '
        'directions and every reading comfort', (tester) async {
      for (final variant in ThemeVariantId.values) {
        final services = await _pump(tester, _workspace(), variant: variant);
        expect(tester.takeException(), isNull);
        expect(
          (tester
                      .widget<AnimatedContainer>(
                        find.byKey(const Key('workspace-surface')),
                      )
                      .decoration
                  as BoxDecoration?)
              ?.color,
          services.get<SurfaceTokenEngine>().surfaceOf(
            SurfaceRole.scene,
            variant,
          ),
        );
      }

      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          _workspace(),
          appearance: AppearanceState(readingComfort: comfort),
        );
        expect(tester.takeException(), isNull);
      }

      for (final direction in TextDirection.values) {
        await _pump(
          tester,
          _workspace(
            channel: MentoraWorkspaceNavigationChannel.rail,
            rail: _rail(),
          ),
          direction: direction,
        );
        expect(tester.takeException(), isNull);
      }

      // The way through the product follows the reading direction.
      await _pump(
        tester,
        _workspace(
          channel: MentoraWorkspaceNavigationChannel.rail,
          rail: _rail(),
        ),
      );
      final ltr = tester.getRect(find.byType(MentoraNavigationRail));
      await _pump(
        tester,
        _workspace(
          channel: MentoraWorkspaceNavigationChannel.rail,
          rail: _rail(),
        ),
        direction: TextDirection.rtl,
      );
      expect(
        tester.getRect(find.byType(MentoraNavigationRail)).left,
        greaterThan(ltr.left),
      );
    });

    testWidgets('every transition comes from the Motion Engine: None '
        'silences it', (tester) async {
      const appearance = AppearanceState();
      final services = await _pump(tester, _workspace());
      expect(
        tester
            .widget<AnimatedContainer>(
              find.byKey(const Key('workspace-surface')),
            )
            .duration,
        services.get<MotionEngine>().durationFor(
          MotionIntention.montrerLaContinuite,
          appearance,
        ),
      );

      await _pump(
        tester,
        _workspace(),
        appearance: const AppearanceState(motion: MotionPreference.none),
      );
      expect(
        tester
            .widget<AnimatedContainer>(
              find.byKey(const Key('workspace-surface')),
            )
            .duration,
        Duration.zero,
      );
    });

    testWidgets('outside the Design Kit the context refuses to build — '
        'fail closed', (tester) async {
      await tester.pumpWidget(MaterialApp(home: _workspace()));
      expect(tester.takeException(), isStateError);
    });
  });

  group('Governance — the executable scans ship with the component', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    Iterable<File> contextFiles() =>
        dartFilesOf('lib/foundation/design_kit/structure/workspace');

    test('no framework container survives in a working context: Flutter '
        'stays a primitive', () {
      final forbidden = <String, RegExp>{
        'Scaffold': RegExp(r'(?<![A-Za-z])Scaffold\('),
        'Drawer': RegExp(r'(?<![A-Za-z])Drawer\('),
        'BottomNavigationBar': RegExp(
          r'(?<![A-Za-z])BottomNavigationBar(?![A-Za-z])',
        ),
        'NavigationBar': RegExp(r'(?<![A-Za-z])NavigationBar(?![A-Za-z])'),
        'AppBar': RegExp(r'(?<![A-Za-z])AppBar\('),
        'TabBar': RegExp(r'(?<![A-Za-z])TabBar(?![A-Za-z])'),
        'SearchAnchor': RegExp(r'(?<![A-Za-z])SearchAnchor(?![A-Za-z])'),
        'showDialog': RegExp(r'(?<![A-Za-z])showDialog(?![A-Za-z])'),
        'showModalBottomSheet': RegExp(
          r'(?<![A-Za-z])showModalBottomSheet(?![A-Za-z])',
        ),
        'ScaffoldMessenger': RegExp(
          r'(?<![A-Za-z])ScaffoldMessenger(?![A-Za-z])',
        ),
      };
      for (final file in contextFiles()) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a working context is assembled from '
                'official components — never from a ${entry.key}',
          );
        }
      }
    });

    test('a working context knows no address, no platform and no '
        'measure', () {
      // Structural, never lexical: these are identifiers of the code.
      final forbidden = <String, RegExp>{
        'an address': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|routeName|pushNamed|'
          r'MaterialPageRoute|Uri)(?![A-Za-z])',
        ),
        'a route type': RegExp(r'(?<![A-Za-z])Route<'),
        'a platform': RegExp(
          r'(?<![A-Za-z])(Platform|TargetPlatform|defaultTargetPlatform|'
          r'kIsWeb|isAndroid|isIOS)(?![A-Za-z])',
        ),
        'a measure of the screen': RegExp(
          r'(?<![A-Za-z])(MediaQuery|LayoutBuilder|ResponsiveEngine|'
          r'Breakpoint\w*|OrientationBuilder)(?![A-Za-z])',
        ),
      };
      final files = contextFiles();
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a working context never carries '
                '${entry.key} — the application decides, the context '
                'expresses',
          );
        }
      }
    });

    test('a working context knows no business and no data', () {
      final forbidden = <String, RegExp>{
        'a business domain': RegExp(
          r'(?<![A-Za-z])(Wallet|Orders?|Marketplace|Business|Inventory|'
          r'Payments?|Messages?|Consultation|Dashboard|Profile|'
          r'Analytics|Settings|Invoice|Facture|Product|Chat)(?![a-z])',
        ),
        'a model or a collection': RegExp(
          r'(?<![A-Za-z])(fromJson|toJson|Model|Repository|Entity|'
          r'HttpClient|Firestore|FirebaseFirestore)(?![A-Za-z])',
        ),
        'a selection of data': RegExp(
          r'\.(where|firstWhere|lastWhere|singleWhere|sort|reduce|fold)\(',
        ),
      };
      for (final file in contextFiles()) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a working context never carries '
                '${entry.key}',
          );
        }
      }
    });

    test('a working context rebuilds nothing, reads no ambient theme '
        'and codes no value', () {
      final forbidden = <String, RegExp>{
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'a coded padding': RegExp(r'(EdgeInsets\.\w+\(\s*[0-9]|Padding\()'),
        'a coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'a coded extent': RegExp(r'(width|height|spacing):\s*[1-9]'),
        'a coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
        'a scroll view of its own': RegExp(
          r'(?<![A-Za-z])(ListView|SingleChildScrollView|CustomScrollView|'
          r'ScrollController|NestedScrollView)(?![A-Za-z])',
        ),
      };
      for (final file in contextFiles()) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a working context never carries '
                '${entry.key}',
          );
        }
      }
    });

    test('no zone of a working context is an untyped widget', () {
      final untyped = RegExp(r'final\s+Widget\??\s+\w+;');
      for (final file in contextFiles()) {
        expect(
          untyped.hasMatch(file.readAsStringSync()),
          isFalse,
          reason:
              '${file.path}: where an official type exists, a zone is '
              'never a Widget',
        );
      }
    });

    test('one working context exists in the whole product, and it lives '
        'in the Design Kit', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraWorkspace(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('design_kit/structure/workspace/'));
    });

    test('the official order of the layers exists in exactly one place', () {
      final mounts = <String>[];
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        if (RegExp(r'MentoraDialogHost\(').hasMatch(source) &&
            RegExp(r'MentoraSnackbarHost\(').hasMatch(source)) {
          mounts.add(file.path.replaceAll(r'\', '/'));
        }
      }
      // The application root installs them once; the Design Kit
      // composes them from one shared truth, and never restates it.
      expect(
        mounts,
        contains(
          'lib/foundation/design_kit/components/overlay/'
          'official_layers.dart',
        ),
      );
      for (final path in mounts) {
        expect(
          path.contains('design_kit/structure/'),
          isFalse,
          reason:
              '$path: a structure composes the official layers, it '
              'never restates their order',
        );
      }
    });
  });
}
