import 'dart:io';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/avatar/mentora_avatar.dart';
import 'package:mentora/foundation/design_kit/components/avatar/mentora_avatar_style.dart';
import 'package:mentora/foundation/design_kit/components/badge/mentora_badge.dart';
import 'package:mentora/foundation/design_kit/components/badge/mentora_badge_style.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button_style.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/composition/list_tile/mentora_list_tile.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/navigation_drawer/mentora_navigation_drawer.dart';
import 'package:mentora/foundation/design_kit/structure/navigation_drawer/mentora_navigation_drawer_style.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/drawer_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

void _noop() {}

const List<MentoraDrawerSection> _sections = [
  MentoraDrawerSection(
    destinations: [
      MentoraDrawerDestination(
        id: 'home',
        label: 'Accueil',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
      MentoraDrawerDestination(
        id: 'consultation',
        label: 'Consultations',
        icon: Icons.event_note_outlined,
        selectedIcon: Icons.event_note,
        badge: MentoraBadge(
          variant: MentoraBadgeVariant.information,
          shape: MentoraBadgeShape.dot,
          semanticLabel: 'Nouvelles consultations',
        ),
      ),
    ],
  ),
  MentoraDrawerSection(
    title: 'Espace professionnel',
    destinations: [
      MentoraDrawerDestination(
        id: 'archive',
        label: 'Archives',
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        enabled: false,
      ),
    ],
  ),
];

MentoraListTile get _space => MentoraListTile(
  leading: const MentoraAvatar(
    identity: MentoraAvatarIdentity.initials,
    name: 'Awa Mensah',
    initials: 'AM',
  ),
  headline: 'Awa Mensah',
  supporting: 'Experte — Nutrition',
);

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  MentoraNavigationDrawer drawer, {
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
  TextDirection direction = TextDirection.ltr,
  FocusNode? sceneFocus,
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
        child: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: Stack(
              children: [
                Center(
                  child: TextButton(
                    focusNode: sceneFocus,
                    onPressed: () {},
                    child: const Text('scène'),
                  ),
                ),
                SizedBox(height: 600, child: drawer),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return services;
}

MentoraNavigationDrawer _drawer({
  MentoraNavigationDrawerController? controller,
  MentoraDrawerPresentation presentation = MentoraDrawerPresentation.permanent,
  List<MentoraDrawerSection> sections = _sections,
  ValueChanged<String>? onDestinationSelected,
  VoidCallback? onDismissRequested,
  String semanticLabel = 'Espace de Awa Mensah',
  bool composed = true,
}) {
  return MentoraNavigationDrawer(
    presentation: presentation,
    controller:
        controller ??
        MentoraNavigationDrawerController(
          selectedId: 'home',
          visibility: MentoraDrawerVisibility.opened,
        ),
    sections: sections,
    space: composed ? _space : null,
    semanticLabel: semanticLabel,
    onDismissRequested: onDismissRequested,
    onDestinationSelected: onDestinationSelected ?? (_) {},
    actions: composed
        ? [
            MentoraButton(
              label: 'Paramètres',
              onPressed: _noop,
              variant: MentoraButtonVariant.text,
              size: MentoraButtonSize.small,
            ),
          ]
        : const [],
  );
}

void main() {
  group('A map orients — it never leads', () {
    testWidgets('a destination is an identity: it is reported, and the '
        'map changes nothing by itself', (tester) async {
      final controller = MentoraNavigationDrawerController(
        selectedId: 'home',
        visibility: MentoraDrawerVisibility.opened,
      );
      addTearDown(controller.dispose);
      String? reported;

      await _pump(
        tester,
        _drawer(
          controller: controller,
          onDestinationSelected: (String id) => reported = id,
        ),
      );

      await tester.tap(
        find.byKey(const Key('drawer-destination-consultation')),
      );
      await tester.pump();
      expect(reported, 'consultation');
      expect(controller.selectedId, 'home');

      controller.announceSelection(reported);
      await tester.pumpAndSettle();
      expect(controller.selectedId, 'consultation');
    });

    testWidgets('the place the person is in wears the identity role and '
        'its own mark', (tester) async {
      final services = await _pump(tester, _drawer());
      final colors = services.get<ColorTokenEngine>();

      final here = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('drawer-destination-home')),
          matching: find.byType(Icon),
        ),
      );
      expect(here.icon, Icons.home);
      expect(
        here.color,
        colors.colorOf(ColorRole.primary, ThemeVariantId.light),
      );

      final elsewhere = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('drawer-destination-consultation')),
          matching: find.byType(Icon),
        ),
      );
      expect(elsewhere.icon, Icons.event_note_outlined);
      expect(
        elsewhere.color,
        colors.colorOf(ColorRole.supporting, ThemeVariantId.light),
      );
    });

    testWidgets('a place that cannot be reached is expressed, and never '
        'reported', (tester) async {
      var reported = 0;
      final services = await _pump(
        tester,
        _drawer(onDestinationSelected: (_) => reported++),
      );

      expect(
        tester
            .widget<Icon>(
              find.descendant(
                of: find.byKey(const Key('drawer-destination-archive')),
                matching: find.byType(Icon),
              ),
            )
            .color,
        services.get<ColorTokenEngine>().colorOf(
          ColorRole.unavailable,
          ThemeVariantId.light,
        ),
      );

      await tester.tap(
        find.byKey(const Key('drawer-destination-archive')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(reported, 0);
    });

    testWidgets('the contracts of a map are verified — fail closed', (
      tester,
    ) async {
      await _pump(tester, _drawer(semanticLabel: ''));
      expect(tester.takeException(), isStateError);

      await _pump(tester, _drawer(sections: const []));
      expect(tester.takeException(), isStateError);

      await _pump(
        tester,
        _drawer(
          controller: MentoraNavigationDrawerController(
            selectedId: 'elsewhere',
            visibility: MentoraDrawerVisibility.opened,
          ),
        ),
      );
      expect(tester.takeException(), isStateError);

      // A permanent map belongs to the chrome: it is never put away.
      await _pump(tester, _drawer(onDismissRequested: _noop));
      expect(tester.takeException(), isStateError);
    });
  });

  group('The application announces; the map expresses', () {
    testWidgets('opened and closed are told, never decided', (tester) async {
      final controller = MentoraNavigationDrawerController(selectedId: 'home');
      addTearDown(controller.dispose);
      var reported = 0;

      await _pump(
        tester,
        _drawer(
          controller: controller,
          onDestinationSelected: (_) => reported++,
        ),
      );
      // Closed: the map gave its room back and takes nothing.
      expect(tester.getSize(find.byKey(const Key('drawer-surface'))).width, 0);
      await tester.tap(
        find.byKey(const Key('drawer-destination-consultation')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(reported, 0);

      controller.announceVisibility(MentoraDrawerVisibility.opened);
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const Key('drawer-surface'))).width,
        permanentDrawerSpec.width,
      );
    });

    testWidgets('each presentation is served by its Token spec', (
      tester,
    ) async {
      for (final presentation in MentoraDrawerPresentation.values) {
        await _pump(
          tester,
          _drawer(
            presentation: presentation,
            onDismissRequested: acceptsDismissal(presentation) ? _noop : null,
          ),
        );
        expect(tester.takeException(), isNull);
        // Only a map that passes in front of the scene dims it.
        expect(
          find.byKey(const Key('drawer-scrim')),
          specOf(presentation).dimsScene ? findsOneWidget : findsNothing,
          reason: '${presentation.name} must dim only when it passes',
        );
      }
    });

    testWidgets('asking to be put away is reported, never performed', (
      tester,
    ) async {
      final controller = MentoraNavigationDrawerController(
        selectedId: 'home',
        visibility: MentoraDrawerVisibility.opened,
      );
      addTearDown(controller.dispose);
      var asked = 0;

      await _pump(
        tester,
        _drawer(
          controller: controller,
          presentation: MentoraDrawerPresentation.modal,
          onDismissRequested: () => asked++,
        ),
      );

      await tester.tapAt(const Offset(700, 300));
      await tester.pumpAndSettle();
      expect(asked, 1);
      // The map did not close itself.
      expect(controller.isOpened, isTrue);
    });

    testWidgets('a closed map is inert: no pointer, no announcement', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final controller = MentoraNavigationDrawerController(selectedId: 'home');
      addTearDown(controller.dispose);
      var asked = 0;

      await _pump(
        tester,
        _drawer(
          controller: controller,
          presentation: MentoraDrawerPresentation.modal,
          onDismissRequested: () => asked++,
        ),
      );

      await tester.tapAt(const Offset(700, 300));
      await tester.pump();
      expect(asked, 0);

      // A closed map still says what it is, and that it is closed —
      // while everything it holds stays silent.
      final closed = tester.getSemantics(
        find.bySemanticsLabel('Espace de Awa Mensah'),
      );
      expect(closed.flagsCollection.isExpanded, Tristate.isFalse);
      expect(find.bySemanticsLabel('Accueil'), findsNothing);

      controller.announceVisibility(MentoraDrawerVisibility.opened);
      await tester.pumpAndSettle();
      final opened = tester.getSemantics(
        find.bySemanticsLabel('Espace de Awa Mensah'),
      );
      expect(opened.flagsCollection.isExpanded, Tristate.isTrue);
      expect(find.bySemanticsLabel('Accueil'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('it never takes the focus, and always gives it back', (
      tester,
    ) async {
      final sceneFocus = FocusNode(debugLabel: 'scene');
      addTearDown(sceneFocus.dispose);
      final controller = MentoraNavigationDrawerController(selectedId: 'home');
      addTearDown(controller.dispose);

      await _pump(
        tester,
        _drawer(
          controller: controller,
          presentation: MentoraDrawerPresentation.modal,
          onDismissRequested: _noop,
        ),
        sceneFocus: sceneFocus,
      );

      sceneFocus.requestFocus();
      await tester.pumpAndSettle();
      expect(sceneFocus.hasFocus, isTrue);

      controller.announceVisibility(MentoraDrawerVisibility.opened);
      await tester.pumpAndSettle();
      // The map appeared without taking anything.
      expect(sceneFocus.hasFocus, isTrue);

      controller.announceVisibility(MentoraDrawerVisibility.closed);
      await tester.pumpAndSettle();
      expect(sceneFocus.hasFocus, isTrue, reason: 'the focus comes home');
    });
  });

  group('It composes, and it travels', () {
    testWidgets('the space is a tile, the identity an avatar, the acts '
        'buttons and the states badges', (tester) async {
      await _pump(tester, _drawer());

      expect(find.byType(MentoraListTile), findsOneWidget);
      expect(find.byType(MentoraAvatar), findsOneWidget);
      expect(find.byType(MentoraBadge), findsOneWidget);
      expect(find.byType(MentoraButton), findsOneWidget);
      expect(find.text('Awa Mensah'), findsOneWidget);
      expect(find.text('Espace professionnel'), findsOneWidget);
    });

    testWidgets('every place is a reachable target and a control of its '
        'own', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _drawer());

      for (final id in const ['home', 'consultation', 'archive']) {
        expect(
          tester.getSize(find.byKey(Key('drawer-destination-$id'))).height,
          greaterThanOrEqualTo(48),
        );
      }

      final here = tester.getSemantics(
        find.byKey(const Key('drawer-destination-home')),
      );
      expect(here.label, 'Accueil');
      expect(here.flagsCollection.isButton, isTrue);
      expect(here.flagsCollection.isSelected, Tristate.isTrue);
      handle.dispose();
    });

    testWidgets('the four theme variants, both directions and every '
        'reading comfort are served without special handling', (tester) async {
      for (final variant in ThemeVariantId.values) {
        final services = await _pump(tester, _drawer(), variant: variant);
        expect(
          tester
              .widget<Icon>(
                find.descendant(
                  of: find.byKey(const Key('drawer-destination-home')),
                  matching: find.byType(Icon),
                ),
              )
              .color,
          services.get<ColorTokenEngine>().colorOf(ColorRole.primary, variant),
        );
      }

      for (final direction in TextDirection.values) {
        await _pump(tester, _drawer(), direction: direction);
        expect(tester.takeException(), isNull);
        expect(find.text('Accueil'), findsOneWidget);
      }

      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          _drawer(),
          appearance: AppearanceState(readingComfort: comfort),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('every transition comes from the Motion Engine: None '
        'silences it', (tester) async {
      const appearance = AppearanceState();
      final services = await _pump(tester, _drawer());
      AnimatedContainer surface() => tester.widget<AnimatedContainer>(
        find.byKey(const Key('drawer-surface')),
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
        _drawer(),
        appearance: const AppearanceState(motion: MotionPreference.none),
      );
      expect(surface().duration, Duration.zero);
    });

    testWidgets('outside the Design Kit the map refuses to build — fail '
        'closed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MentoraNavigationDrawer(
              controller: MentoraNavigationDrawerController(
                visibility: MentoraDrawerVisibility.opened,
              ),
              sections: _sections,
              semanticLabel: 'Espace',
              onDestinationSelected: (_) {},
            ),
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

    test('no framework navigation widget survives in the foundation: '
        'Flutter stays a primitive', () {
      final forbidden = <String, RegExp>{
        'Drawer': RegExp(r'(?<![A-Za-z])Drawer\('),
        'NavigationDrawer': RegExp(
          r'(?<![A-Za-z])NavigationDrawer(?![A-Za-z])',
        ),
        'NavigationDrawerDestination': RegExp(
          r'(?<![A-Za-z])NavigationDrawerDestination(?![A-Za-z])',
        ),
        'DrawerController': RegExp(
          r'(?<![A-Za-z])DrawerController(?![A-Za-z])',
        ),
        'BottomNavigationBar': RegExp(
          r'(?<![A-Za-z])BottomNavigationBar(?![A-Za-z])',
        ),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: lateral navigation is a '
                'MentoraNavigationDrawer — never a ${entry.key}',
          );
        }
      }
    });

    test('a structure never knows the platform: the Responsive Engine '
        'decides', () {
      final platform = RegExp(
        r'(?<![A-Za-z])(Platform|TargetPlatform|defaultTargetPlatform|'
        r'kIsWeb|isAndroid|isIOS)(?![A-Za-z])',
      );
      final files = dartFilesOf('lib/foundation/design_kit/structure');
      expect(files, isNotEmpty);
      for (final file in files) {
        expect(
          platform.hasMatch(file.readAsStringSync()),
          isFalse,
          reason:
              '${file.path}: a structure expresses — the platform and '
              'the surface are decided elsewhere',
        );
      }
    });

    test('a structure rebuilds nothing a Core Component owns', () {
      final rebuilds = <String, RegExp>{
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
        'a coded size': RegExp(r'fontSize:'),
        'a coded weight': RegExp(r'FontWeight\.'),
      };
      for (final file in dartFilesOf('lib/foundation/design_kit/structure')) {
        final source = file.readAsStringSync();
        for (final entry in rebuilds.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a structure never rebuilds ${entry.key} — '
                'the component that owns it does',
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
