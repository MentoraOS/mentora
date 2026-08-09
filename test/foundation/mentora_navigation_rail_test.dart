import 'dart:io';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_destination.dart';
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
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/navigation_rail/mentora_navigation_rail.dart';
import 'package:mentora/foundation/design_kit/structure/navigation_rail/mentora_navigation_rail_style.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/navigation_rail_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

const List<MentoraDestination> _places = [
  MentoraDestination(
    id: 'home',
    label: 'Accueil',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  MentoraDestination(
    id: 'consultation',
    label: 'Consultation',
    icon: Icons.event_note_outlined,
    selectedIcon: Icons.event_note,
    badge: MentoraBadge(
      variant: MentoraBadgeVariant.information,
      shape: MentoraBadgeShape.dot,
      semanticLabel: 'Nouvelles consultations',
    ),
  ),
  MentoraDestination(
    id: 'archive',
    label: 'Archives',
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
    enabled: false,
  ),
];

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  MentoraNavigationRail rail, {
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
        child: Directionality(
          textDirection: direction,
          // A structure lives beside the content: it is given a bounded
          // height and takes the width it declares.
          child: Scaffold(
            body: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(height: 480, child: rail),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return services;
}

MentoraNavigationRail _rail({
  MentoraNavigationRailDisplay display = MentoraNavigationRailDisplay.compact,
  MentoraNavigationRailChrome chrome = MentoraNavigationRailChrome.surface,
  MentoraNavigationRailController? controller,
  List<MentoraDestination> destinations = _places,
  ValueChanged<String>? onDestinationSelected,
  MentoraNavigationRailToggle? displayToggle,
  bool composed = false,
}) {
  return MentoraNavigationRail(
    display: display,
    chrome: chrome,
    controller: controller,
    destinations: destinations,
    displayToggle: displayToggle,
    onDestinationSelected: onDestinationSelected ?? (_) {},
    leading: composed
        ? const MentoraAvatar(
            identity: MentoraAvatarIdentity.company,
            name: 'Mentora SA',
            initials: 'MS',
          )
        : null,
    trailing: composed
        ? [
            MentoraButton(
              label: 'Aide',
              onPressed: () {},
              variant: MentoraButtonVariant.text,
              size: MentoraButtonSize.small,
            ),
          ]
        : const [],
  );
}

AnimatedContainer _surfaceOf(WidgetTester tester) {
  return tester.widget<AnimatedContainer>(
    find.byKey(const Key('rail-surface')),
  );
}

BoxDecoration _decorationOf(WidgetTester tester) =>
    _surfaceOf(tester).decoration! as BoxDecoration;

void main() {
  group('A destination is an identity, never a position', () {
    testWidgets('the selection travels by identity — the API carries no '
        'index at all', (tester) async {
      // The signature itself is the proof: what is reported is a
      // String identity, and it is what the application announces back.
      final controller = MentoraNavigationRailController('home');
      addTearDown(controller.dispose);
      String? reported;

      await _pump(
        tester,
        _rail(
          controller: controller,
          onDestinationSelected: (String id) => reported = id,
        ),
      );

      await tester.tap(find.byKey(const Key('rail-destination-consultation')));
      await tester.pump();
      expect(reported, 'consultation');
      // The structure did NOT move by itself: it reported, nothing more.
      expect(controller.selectedId, 'home');

      controller.announceSelection(reported);
      await tester.pumpAndSettle();
      expect(controller.selectedId, 'consultation');
    });

    testWidgets('a place announced that the structure does not present '
        'is refused — a structure never guesses', (tester) async {
      final controller = MentoraNavigationRailController('elsewhere');
      addTearDown(controller.dispose);

      await _pump(tester, _rail(controller: controller));
      expect(tester.takeException(), isStateError);
    });

    testWidgets('two places never share one identity, and none is '
        'nameless', (tester) async {
      await _pump(
        tester,
        _rail(
          destinations: const [
            MentoraDestination(
              id: 'home',
              label: 'Accueil',
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
            ),
            MentoraDestination(
              id: 'home',
              label: 'Encore',
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
            ),
          ],
        ),
      );
      expect(tester.takeException(), isStateError);

      await _pump(
        tester,
        _rail(
          destinations: const [
            MentoraDestination(
              id: 'home',
              label: '',
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
            ),
          ],
        ),
      );
      expect(tester.takeException(), isStateError);

      await _pump(tester, _rail(destinations: const []));
      expect(tester.takeException(), isStateError);
    });

    testWidgets('the chosen place wears the identity role and its own '
        'mark', (tester) async {
      final controller = MentoraNavigationRailController('home');
      addTearDown(controller.dispose);
      final services = await _pump(tester, _rail(controller: controller));
      final colors = services.get<ColorTokenEngine>();

      final chosen = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('rail-destination-home')),
          matching: find.byType(Icon),
        ),
      );
      expect(chosen.icon, Icons.home);
      expect(
        chosen.color,
        colors.colorOf(ColorRole.primary, ThemeVariantId.light),
      );

      final other = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('rail-destination-consultation')),
          matching: find.byType(Icon),
        ),
      );
      expect(other.icon, Icons.event_note_outlined);
      expect(
        other.color,
        colors.colorOf(ColorRole.supporting, ThemeVariantId.light),
      );
    });
  });

  group('The application decides how much it shows', () {
    testWidgets('each display is served by its Token, and only the '
        'expanded one says the words', (tester) async {
      for (final display in MentoraNavigationRailDisplay.values) {
        await _pump(tester, _rail(display: display));
        expect(
          tester.getSize(find.byType(MentoraNavigationRail)).width,
          specOf(display).width,
        );
        expect(
          find.text('Accueil'),
          specOf(display).showsWords ? findsOneWidget : findsNothing,
          reason: '${display.name} must show its words as declared',
        );
      }
    });

    testWidgets('the structure only offers the change of display — the '
        'application performs it', (tester) async {
      var asked = 0;
      await _pump(
        tester,
        _rail(
          displayToggle: MentoraNavigationRailToggle(
            label: 'Afficher',
            onInvoke: () => asked++,
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('rail-display-toggle')));
      await tester.pump();
      expect(asked, 1);
      // The structure did not change on its own.
      expect(
        tester.getSize(find.byType(MentoraNavigationRail)).width,
        compactRailSpec.width,
      );
    });

    testWidgets('every chrome delimits the structure with a role', (
      tester,
    ) async {
      final services = await _services();
      final colors = services.get<ColorTokenEngine>();
      final surfaces = services.get<SurfaceTokenEngine>();

      await _pump(tester, _rail());
      expect(
        _decorationOf(tester).color,
        surfaces.surfaceOf(SurfaceRole.primarySurface, ThemeVariantId.light),
      );
      expect(find.byKey(const Key('rail-divider')), findsOneWidget);

      await _pump(tester, _rail(chrome: MentoraNavigationRailChrome.floating));
      expect(
        (_decorationOf(tester).border! as Border).top.color,
        colors.colorOf(ColorRole.outline, ThemeVariantId.light),
      );
      expect(find.byKey(const Key('rail-divider')), findsNothing);

      await _pump(
        tester,
        _rail(chrome: MentoraNavigationRailChrome.transparent),
      );
      expect(_decorationOf(tester).color, isNull);
    });
  });

  group('It accompanies, and it never competes', () {
    testWidgets('it composes the official components and redefines none '
        'of them', (tester) async {
      await _pump(
        tester,
        _rail(display: MentoraNavigationRailDisplay.expanded, composed: true),
      );

      expect(find.byType(MentoraAvatar), findsOneWidget);
      expect(find.byType(MentoraBadge), findsOneWidget);
      expect(find.byType(MentoraButton), findsOneWidget);
      expect(find.text('Accueil'), findsOneWidget);
    });

    testWidgets('every place is a reachable target and a control of its '
        'own', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = MentoraNavigationRailController('home');
      addTearDown(controller.dispose);
      await _pump(tester, _rail(controller: controller));

      for (final place in _places) {
        expect(
          tester
              .getSize(find.byKey(Key('rail-destination-${place.id}')))
              .height,
          greaterThanOrEqualTo(48),
        );
      }

      final chosen = tester.getSemantics(
        find.byKey(const Key('rail-destination-home')),
      );
      expect(chosen.label, 'Accueil');
      expect(chosen.flagsCollection.isButton, isTrue);
      expect(chosen.flagsCollection.isSelected, Tristate.isTrue);
      handle.dispose();
    });

    testWidgets('a place that cannot be reached is expressed, and never '
        'reported', (tester) async {
      var reported = 0;
      final services = await _pump(
        tester,
        _rail(onDestinationSelected: (_) => reported++),
      );

      final closed = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('rail-destination-archive')),
          matching: find.byType(Icon),
        ),
      );
      expect(
        closed.color,
        services.get<ColorTokenEngine>().colorOf(
          ColorRole.unavailable,
          ThemeVariantId.light,
        ),
      );

      await tester.tap(
        find.byKey(const Key('rail-destination-archive')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(reported, 0);
    });

    testWidgets('a structure the application put to rest is veiled and '
        'reports nothing', (tester) async {
      var reported = 0;
      final controller = MentoraNavigationRailController('home')
        ..announceAvailability(enabled: false);
      addTearDown(controller.dispose);

      await _pump(
        tester,
        _rail(controller: controller, onDestinationSelected: (_) => reported++),
      );
      expect(
        tester.widget<Opacity>(find.byKey(const Key('rail-presence'))).opacity,
        navigationRailDisabledVeilOpacity,
      );

      await tester.tap(
        find.byKey(const Key('rail-destination-consultation')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(reported, 0);
    });

    testWidgets('the keyboard reaches the places, and the focus is '
        'expressed', (tester) async {
      final controller = MentoraNavigationRailController('home');
      addTearDown(controller.dispose);
      final services = await _pump(tester, _rail(controller: controller));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Whatever the focus landed on, the focus role expresses it.
      final focused = tester
          .widgetList<Icon>(find.byType(Icon))
          .where(
            (icon) =>
                icon.color ==
                services.get<ColorTokenEngine>().colorOf(
                  ColorRole.focus,
                  ThemeVariantId.light,
                ),
          );
      expect(focused, isNotEmpty);
    });

    testWidgets('the four theme variants, both directions and every '
        'reading comfort are served without special handling', (tester) async {
      for (final variant in ThemeVariantId.values) {
        final services = await _pump(tester, _rail(), variant: variant);
        expect(
          _decorationOf(tester).color,
          services.get<SurfaceTokenEngine>().surfaceOf(
            SurfaceRole.primarySurface,
            variant,
          ),
        );
      }

      for (final direction in TextDirection.values) {
        await _pump(
          tester,
          _rail(display: MentoraNavigationRailDisplay.expanded),
          direction: direction,
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Accueil'), findsOneWidget);
      }

      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          _rail(),
          appearance: AppearanceState(readingComfort: comfort),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('every transition comes from the Motion Engine: None '
        'silences it', (tester) async {
      const appearance = AppearanceState();
      final services = await _pump(tester, _rail());
      expect(
        _surfaceOf(tester).duration,
        services.get<MotionEngine>().durationFor(
          MotionIntention.accompagner,
          appearance,
        ),
      );

      await _pump(
        tester,
        _rail(),
        appearance: const AppearanceState(motion: MotionPreference.none),
      );
      expect(_surfaceOf(tester).duration, Duration.zero);
    });

    testWidgets('outside the Design Kit the structure refuses to build '
        '— fail closed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MentoraNavigationRail(
              destinations: _places,
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

    test('no framework rail or drawer survives in the foundation: '
        'Flutter stays a primitive', () {
      final forbidden = <String, RegExp>{
        'NavigationRail': RegExp(r'(?<![A-Za-z])NavigationRail(?![A-Za-z])'),
        'NavigationRailDestination': RegExp(
          r'(?<![A-Za-z])NavigationRailDestination(?![A-Za-z])',
        ),
        'NavigationDrawer': RegExp(
          r'(?<![A-Za-z])NavigationDrawer(?![A-Za-z])',
        ),
        'Drawer': RegExp(r'(?<![A-Za-z])Drawer\('),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: navigation is a MentoraNavigationRail — '
                'never a ${entry.key}',
          );
        }
      }
    });

    test('a structure knows no address, measures no screen and takes no '
        'responsive decision', () {
      // Structural, never lexical: these are identifiers of the code.
      final forbidden = <String, RegExp>{
        'an address': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|routeName|pushNamed|'
          r'MaterialPageRoute)(?![A-Za-z])',
        ),
        'a route type': RegExp(r'(?<![A-Za-z])Route<'),
        'a measure of the screen': RegExp(
          r'(?<![A-Za-z])(MediaQuery|LayoutBuilder|ResponsiveEngine)'
          r'(?![A-Za-z])',
        ),
      };
      final files = dartFilesOf('lib/foundation/design_kit/structure');
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a structure never carries ${entry.key} — '
                'the application decides, the structure expresses',
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
