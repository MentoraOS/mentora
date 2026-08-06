import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/bottom_sheet/mentora_bottom_sheet_host.dart';
import 'package:mentora/foundation/design_kit/components/bottom_sheet/mentora_bottom_sheet_service.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button_style.dart';
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
import 'package:mentora/foundation/design_kit/structure/app_bar/mentora_app_bar.dart';
import 'package:mentora/foundation/design_kit/structure/navigation_drawer/mentora_navigation_drawer.dart';
import 'package:mentora/foundation/design_kit/structure/navigation_drawer/mentora_navigation_drawer_style.dart';
import 'package:mentora/foundation/design_kit/structure/navigation_rail/mentora_navigation_rail.dart';
import 'package:mentora/foundation/design_kit/structure/navigation_rail/mentora_navigation_rail_style.dart';
import 'package:mentora/foundation/design_kit/structure/page_scaffold/mentora_page_scaffold.dart';
import 'package:mentora/foundation/design_kit/structure/search_bar/mentora_search_bar.dart';
import 'package:mentora/foundation/design_kit/structure/search_bar/mentora_search_bar_style.dart';
import 'package:mentora/foundation/design_kit/structure/tabs/mentora_tabs.dart';
import 'package:mentora/foundation/design_kit/structure/tabs/mentora_tabs_style.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

void _noop() {}

const List<MentoraNavigationRailDestination> _places = [
  MentoraNavigationRailDestination(
    id: 'home',
    label: 'Accueil',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  MentoraNavigationRailDestination(
    id: 'consultation',
    label: 'Consultation',
    icon: Icons.event_note_outlined,
    selectedIcon: Icons.event_note,
  ),
];

const List<MentoraDrawerSection> _sections = [
  MentoraDrawerSection(
    destinations: [
      MentoraDrawerDestination(
        id: 'home',
        label: 'Accueil',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
    ],
  ),
];

const List<MentoraTab> _facets = [
  MentoraTab(id: 'overview', label: 'Vue d’ensemble'),
  MentoraTab(id: 'sessions', label: 'Séances'),
];

/// The content the application owns — recognisable, and never touched.
const Widget _content = MentoraText(
  'Le contenu appartient à l’application.',
  key: Key('page-content'),
  role: MentoraTextRole.body,
);

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  MentoraPageScaffold page, {
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
        child: Directionality(textDirection: direction, child: page),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return services;
}

MentoraPageScaffold _page({
  MentoraAppBar? place,
  MentoraNavigationRail? rail,
  MentoraNavigationDrawer? orientation,
  MentoraTabs? facets,
  MentoraSearchBar? intention,
  List<MentoraButton> acts = const [],
  MentoraDialogService? dialogs,
  MentoraBottomSheetService? sheets,
  MentoraSnackbarService? messages,
  String semanticLabel = 'Consultations',
  Widget content = _content,
}) {
  return MentoraPageScaffold(
    semanticLabel: semanticLabel,
    place: place,
    rail: rail,
    orientation: orientation,
    facets: facets,
    intention: intention,
    acts: acts,
    dialogs: dialogs,
    sheets: sheets,
    messages: messages,
    content: content,
  );
}

MentoraNavigationRail get _rail => MentoraNavigationRail(
  destinations: _places,
  controller: MentoraNavigationRailController('home'),
  onDestinationSelected: (_) {},
);

MentoraNavigationDrawer _drawer(MentoraDrawerPresentation presentation) {
  return MentoraNavigationDrawer(
    presentation: presentation,
    controller: MentoraNavigationDrawerController(
      selectedId: 'home',
      visibility: MentoraDrawerVisibility.opened,
    ),
    sections: _sections,
    semanticLabel: 'Espace de Awa Mensah',
    onDestinationSelected: (_) {},
    onDismissRequested: presentation == MentoraDrawerPresentation.permanent
        ? null
        : _noop,
  );
}

MentoraTabs get _tabs => MentoraTabs(
  controller: MentoraTabsController('overview'),
  tabs: _facets,
  onTabSelected: (_) {},
);

MentoraSearchBar get _search => MentoraSearchBar(
  controller: MentoraSearchController(),
  placeholder: 'Rechercher',
  semanticLabel: 'Rechercher dans Mentora',
  onQueryChanged: (_) {},
);

void main() {
  group('A page gathers a context — it decides nothing', () {
    testWidgets('every zone it is given is composed, and each stays '
        'itself', (tester) async {
      await _pump(
        tester,
        _page(
          place: const MentoraAppBar(title: 'Consultations'),
          rail: _rail,
          facets: _tabs,
          intention: _search,
          acts: [
            MentoraButton(
              label: 'Confirmer',
              onPressed: _noop,
              size: MentoraButtonSize.small,
            ),
          ],
        ),
      );

      expect(find.byType(MentoraAppBar), findsOneWidget);
      expect(find.byType(MentoraNavigationRail), findsOneWidget);
      expect(find.byType(MentoraTabs), findsOneWidget);
      expect(find.byType(MentoraSearchBar), findsOneWidget);
      expect(find.byType(MentoraButton), findsWidgets);
      expect(find.byKey(const Key('page-content')), findsOneWidget);
    });

    testWidgets('a page given nothing is still a page', (tester) async {
      await _pump(tester, _page());

      expect(find.byKey(const Key('page-content')), findsOneWidget);
      expect(find.byType(MentoraAppBar), findsNothing);
      expect(find.byType(MentoraNavigationRail), findsNothing);
      expect(find.byKey(const Key('page-acts-divider')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the content is handed over untouched: nothing wraps '
        'it, nothing pads it', (tester) async {
      await _pump(tester, _page());

      // The proof is geometric: with no zone beside it, the content
      // starts exactly where the page starts. Nothing was inset,
      // wrapped or reordered around it.
      expect(
        tester.getTopLeft(find.byKey(const Key('page-content'))),
        tester.getTopLeft(find.byType(MentoraPageScaffold)),
        reason: 'a page adds nothing around the content it carries',
      );
    });

    testWidgets('a context that cannot be named is refused — fail '
        'closed', (tester) async {
      await _pump(tester, _page(semanticLabel: ''));
      expect(tester.takeException(), isStateError);
    });

    testWidgets('the acts a page keeps at hand stand under their own '
        'line', (tester) async {
      final services = await _pump(
        tester,
        _page(
          acts: [
            MentoraButton(
              label: 'Confirmer',
              onPressed: _noop,
              size: MentoraButtonSize.small,
            ),
          ],
        ),
      );

      expect(
        tester
            .widget<Divider>(find.byKey(const Key('page-acts-divider')))
            .color,
        services.get<ColorTokenEngine>().colorOf(
          ColorRole.divider,
          ThemeVariantId.light,
        ),
      );
      expect(find.text('Confirmer'), findsOneWidget);
    });
  });

  group('It places what it is given — it never chooses', () {
    testWidgets('a map that stands beside takes its own room; one that '
        'passes in front takes none', (tester) async {
      for (final presentation in const [
        MentoraDrawerPresentation.permanent,
        MentoraDrawerPresentation.dismissible,
      ]) {
        await _pump(tester, _page(orientation: _drawer(presentation)));
        final contentStart = tester
            .getTopLeft(find.byKey(const Key('page-content')))
            .dx;
        expect(
          contentStart,
          greaterThan(0),
          reason: '${presentation.name} stands beside the content',
        );
      }

      await _pump(
        tester,
        _page(orientation: _drawer(MentoraDrawerPresentation.modal)),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('page-content'))).dx,
        0,
        reason: 'a map that passes in front takes no room',
      );
    });

    testWidgets('the layers are composed only when the page is given '
        'their service — never recreated', (tester) async {
      await _pump(tester, _page());
      expect(find.byType(MentoraDialogHost), findsNothing);
      expect(find.byType(MentoraBottomSheetHost), findsNothing);
      expect(find.byType(MentoraSnackbarHost), findsNothing);

      final dialogs = MentoraDialogService();
      final sheets = MentoraBottomSheetService();
      final messages = MentoraSnackbarService();
      addTearDown(dialogs.dispose);
      addTearDown(sheets.dispose);
      addTearDown(messages.dispose);

      await _pump(
        tester,
        _page(dialogs: dialogs, sheets: sheets, messages: messages),
      );
      expect(find.byType(MentoraDialogHost), findsOneWidget);
      expect(find.byType(MentoraBottomSheetHost), findsOneWidget);
      expect(find.byType(MentoraSnackbarHost), findsOneWidget);
    });

    testWidgets('the page rests on the scene of its theme', (tester) async {
      for (final variant in ThemeVariantId.values) {
        final services = await _pump(tester, _page(), variant: variant);
        final decoration =
            tester
                    .widget<AnimatedContainer>(
                      find.byKey(const Key('page-surface')),
                    )
                    .decoration
                as BoxDecoration;
        expect(
          decoration.color,
          services.get<SurfaceTokenEngine>().surfaceOf(
            SurfaceRole.scene,
            variant,
          ),
        );
      }
    });
  });

  group('It is reachable, and it travels', () {
    testWidgets('each zone travels as its own focus group, and the '
        'focus stays where it was put', (tester) async {
      final focus = FocusNode(debugLabel: 'content');
      addTearDown(focus.dispose);

      await _pump(
        tester,
        _page(
          place: const MentoraAppBar(title: 'Consultations'),
          rail: _rail,
          content: TextButton(
            focusNode: focus,
            onPressed: _noop,
            child: const Text('contenu'),
          ),
        ),
      );

      focus.requestFocus();
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isTrue);

      // Every zone is a group of its own: assembling a page never
      // moves the focus that was already given.
      expect(find.byType(FocusTraversalGroup), findsWidgets);
      expect(focus.hasFocus, isTrue);
    });

    testWidgets('it announces the context it gathers', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _page());

      expect(
        tester.getSemantics(find.byType(MentoraPageScaffold)).label,
        contains('Consultations'),
      );
      handle.dispose();
    });

    testWidgets('both directions and every reading comfort are served '
        'without special handling', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _page(rail: _rail), direction: direction);
        expect(tester.takeException(), isNull);
        expect(find.byKey(const Key('page-content')), findsOneWidget);
      }

      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          _page(),
          appearance: AppearanceState(readingComfort: comfort),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('every transition comes from the Motion Engine: None '
        'silences it', (tester) async {
      const appearance = AppearanceState();
      final services = await _pump(tester, _page());
      AnimatedContainer surface() => tester.widget<AnimatedContainer>(
        find.byKey(const Key('page-surface')),
      );
      expect(
        surface().duration,
        services.get<MotionEngine>().durationFor(
          MotionIntention.montrerLaContinuite,
          appearance,
        ),
      );

      await _pump(
        tester,
        _page(),
        appearance: const AppearanceState(motion: MotionPreference.none),
      );
      expect(surface().duration, Duration.zero);
    });

    testWidgets('outside the Design Kit the page refuses to build — '
        'fail closed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MentoraPageScaffold(
            semanticLabel: 'Consultations',
            content: SizedBox.shrink(),
          ),
        ),
      );
      expect(tester.takeException(), isStateError);
    });
  });

  group('Governance — the executable scans ship with the component', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    test('no framework scaffold survives in the Design Kit: Flutter '
        'stays a primitive', () {
      final forbidden = <String, RegExp>{
        'Scaffold': RegExp(r'(?<![A-Za-z])Scaffold\('),
        'ScaffoldMessenger': RegExp(
          r'(?<![A-Za-z])ScaffoldMessenger(?![A-Za-z])',
        ),
        'FloatingActionButton': RegExp(
          r'(?<![A-Za-z])FloatingActionButton(?![A-Za-z])',
        ),
        'NestedScrollView': RegExp(
          r'(?<![A-Za-z])NestedScrollView(?![A-Za-z])',
        ),
      };
      for (final file in dartFilesOf('lib/foundation/design_kit')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a page is a MentoraPageScaffold — never '
                'a ${entry.key}',
          );
        }
      }
    });

    test('a page assembles structures and rebuilds none of them', () {
      final rebuilds = <String, RegExp>{
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
        'its own place': RegExp(r'(?<![A-Za-z])AppBar\('),
        'its own layers': RegExp(
          r'(?<![A-Za-z])(Dialog|BottomSheet|SnackBar)\(',
        ),
        'a coded size': RegExp(r'fontSize:'),
      };
      final files = dartFilesOf(
        'lib/foundation/design_kit/structure/page_scaffold',
      );
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in rebuilds.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a page never rebuilds ${entry.key} — the '
                'component that owns it does',
          );
        }
      }
    });

    test('a page knows no business: it names no domain of the '
        'product', () {
      // A page assembles components; it must not even be able to
      // speak of what they carry.
      const domains = [
        'Wallet',
        'Consultation',
        'Business',
        'Chat',
        'Invoice',
        'Facture',
        'Product',
        'Dashboard',
        'Profile',
        'Settings',
      ];
      for (final file in dartFilesOf(
        'lib/foundation/design_kit/structure/page_scaffold',
      )) {
        final source = file.readAsStringSync();
        for (final domain in domains) {
          expect(
            RegExp('(?<![A-Za-z])$domain(?![A-Za-z])').hasMatch(source),
            isFalse,
            reason: '${file.path}: a page knows no business ($domain)',
          );
        }
      }
    });

    test('no Core Component reads the ambient theme, and no colour, '
        'padding, radius or duration is coded outside the Tokens', () {
      final coded = <String, RegExp>{
        'ambient theme': RegExp(r'Theme\.of\('),
        'coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'coded padding': RegExp(r'EdgeInsets\.\w+\(\s*[0-9]'),
        'coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final normalized = file.path.replaceAll(r'\', '/');
        final source = file.readAsStringSync();
        for (final entry in coded.entries) {
          if (entry.key != 'ambient theme' &&
              normalized.contains('design_kit/tokens/')) {
            continue;
          }
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: ${entry.key} — everything is a Token',
          );
        }
      }
    });
  });
}
