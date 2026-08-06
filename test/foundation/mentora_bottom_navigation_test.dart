import 'dart:io';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/app/mentora_foundation_app.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/badge/mentora_badge.dart';
import 'package:mentora/foundation/design_kit/components/badge/mentora_badge_style.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/bottom_navigation/mentora_bottom_navigation.dart';
import 'package:mentora/foundation/design_kit/structure/bottom_navigation/mentora_bottom_navigation_style.dart';
import 'package:mentora/foundation/design_kit/structure/page_scaffold/mentora_page_scaffold.dart';
import 'package:mentora/foundation/design_kit/structure/workspace/mentora_workspace.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/bottom_navigation_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

const MentoraBadge _badge = MentoraBadge(
  variant: MentoraBadgeVariant.information,
  shape: MentoraBadgeShape.compact,
  size: MentoraBadgeSize.small,
  label: '3',
  semanticLabel: '3 notifications non lues',
);

const List<MentoraBottomNavigationDestination> _places = [
  MentoraBottomNavigationDestination(
    id: 'home',
    label: 'Accueil',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  MentoraBottomNavigationDestination(
    id: 'consultation',
    label: 'Consultation',
    icon: Icons.event_note_outlined,
    selectedIcon: Icons.event_note,
  ),
  MentoraBottomNavigationDestination(
    id: 'notifications',
    label: 'Notifications',
    icon: Icons.notifications_outlined,
    selectedIcon: Icons.notifications,
    badge: _badge,
  ),
  MentoraBottomNavigationDestination(
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

MentoraBottomNavigation _navigation({
  List<MentoraBottomNavigationDestination> destinations = _places,
  String? selectedDestinationId = 'home',
  ValueChanged<String>? onDestinationRequested,
}) {
  return MentoraBottomNavigation(
    destinations: destinations,
    selectedDestinationId: selectedDestinationId,
    semanticLabel: 'Navigation principale',
    onDestinationRequested: onDestinationRequested ?? (_) {},
  );
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget structure, {
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
  TextDirection direction = TextDirection.ltr,
  double textScale = 1.0,
}) async {
  final services = await _services();
  await tester.pumpWidget(
    MaterialApp(
      theme: services.get<ThemeEngine>().themeForVariant(variant),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: DesignKitScope(
            colors: services.get<ColorTokenEngine>(),
            typography: services.get<TypographyTokenEngine>(),
            spacing: services.get<SpacingTokenEngine>(),
            surfaces: services.get<SurfaceTokenEngine>(),
            elevation: services
                .get<ElevationTokenEngine<ElevationExpression>>(),
            motion: services.get<MotionEngine>(),
            accessibility: services.get<AccessibilityEngine>(),
            appearance: appearance,
            variant: variant,
            child: Directionality(
              textDirection: direction,
              child: Align(alignment: Alignment.bottomCenter, child: structure),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return services;
}

Finder _destination(String id) =>
    find.byKey(Key('bottom-navigation-destination-$id'));

AnimatedContainer _capsule(WidgetTester tester, String id) =>
    tester.widget<AnimatedContainer>(
      find.byKey(Key('bottom-navigation-capsule-$id')),
    );

Color? _capsuleColor(AnimatedContainer capsule) =>
    (capsule.decoration as BoxDecoration?)?.color;

void main() {
  group('MentoraBottomNavigation — the principal level of the product', () {
    testWidgets('a destination is an identity: what is reported is the '
        'id, and never a position', (tester) async {
      final reported = <String>[];
      await _pump(tester, _navigation(onDestinationRequested: reported.add));

      await tester.tap(_destination('consultation'));
      await tester.pumpAndSettle();
      await tester.tap(_destination('notifications'));
      await tester.pumpAndSettle();

      expect(reported, ['consultation', 'notifications']);
    });

    testWidgets('the structure reports, it never decides: nothing moves '
        'until the application announces it', (tester) async {
      await _pump(tester, _navigation());

      await tester.tap(_destination('consultation'));
      await tester.pumpAndSettle();

      // Where the person is has not changed: only the application
      // decides that, and it was told nothing.
      final scope = DesignKitScope.of(
        tester.element(find.byType(MentoraBottomNavigation)),
      );
      expect(
        _capsuleColor(_capsule(tester, 'home')),
        scope.colors.colorOf(ColorRole.highlight, scope.variant),
      );
      expect(_capsuleColor(_capsule(tester, 'consultation')), isNull);
    });

    testWidgets('where the person already is is not a place to ask for', (
      tester,
    ) async {
      var reported = 0;
      await _pump(
        tester,
        _navigation(onDestinationRequested: (_) => reported++),
      );

      await tester.tap(_destination('home'));
      await tester.pumpAndSettle();

      expect(reported, 0);
    });

    testWidgets('a place that cannot be reached is expressed, and never '
        'reported', (tester) async {
      var reported = 0;
      await _pump(
        tester,
        _navigation(onDestinationRequested: (_) => reported++),
      );

      await tester.tap(_destination('archive'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(reported, 0);
      // It stays visible: the person keeps seeing that it exists.
      expect(
        tester
            .widget<Opacity>(
              find.byKey(const Key('bottom-navigation-presence-archive')),
            )
            .opacity,
        bottomNavigationDisabledVeilOpacity,
      );
      expect(
        tester
            .widget<Opacity>(
              find.byKey(const Key('bottom-navigation-presence-home')),
            )
            .opacity,
        bottomNavigationFullOpacity,
      );
    });

    testWidgets('every destination is a control, named, announcing where '
        'the person is, and reachable', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _navigation());

      for (final place in _places) {
        expect(
          tester.getSize(_destination(place.id)).height,
          greaterThanOrEqualTo(48),
        );
      }

      final chosen = tester.getSemantics(_destination('home'));
      expect(chosen.label, 'Accueil');
      expect(chosen.flagsCollection.isButton, isTrue);
      expect(chosen.flagsCollection.isSelected, Tristate.isTrue);

      final elsewhere = tester.getSemantics(_destination('consultation'));
      expect(elsewhere.flagsCollection.isSelected, Tristate.isFalse);

      final closed = tester.getSemantics(_destination('archive'));
      expect(closed.flagsCollection.isEnabled, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('the words are composed, never rebuilt: they are Mentora '
        'texts at the label role', (tester) async {
      await _pump(tester, _navigation());

      for (final place in _places) {
        final word = tester.widget<MentoraText>(
          find.descendant(
            of: _destination(place.id),
            matching: find.byWidgetPredicate(
              (widget) => widget is MentoraText && widget.data == place.label,
            ),
          ),
        );
        expect(word.role, MentoraTextRole.label);
        expect(word.maxLines, 1);
      }
      expect(find.text('Accueil'), findsOneWidget);
    });

    testWidgets('what happens in a place is composed: the Badge stays '
        'its owner', (tester) async {
      await _pump(tester, _navigation());

      expect(
        find.descendant(
          of: _destination('notifications'),
          matching: find.byType(MentoraBadge),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(MentoraBottomNavigation),
          matching: find.byType(MentoraBadge),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a structure without a contract refuses to build — fail '
        'closed', (tester) async {
      Future<void> refuses(
        List<MentoraBottomNavigationDestination> destinations, {
        String? selectedDestinationId = 'home',
      }) async {
        await _pump(
          tester,
          _navigation(
            destinations: destinations,
            selectedDestinationId: selectedDestinationId,
          ),
        );
        expect(tester.takeException(), isStateError);
      }

      // Below the minimum there is no choice to express.
      await refuses(_places.take(1).toList());
      // Beyond the maximum it is no longer a level, it is a menu.
      await refuses([
        ..._places,
        const MentoraBottomNavigationDestination(
          id: 'a',
          label: 'A',
          icon: Icons.circle_outlined,
          selectedIcon: Icons.circle,
        ),
        const MentoraBottomNavigationDestination(
          id: 'b',
          label: 'B',
          icon: Icons.circle_outlined,
          selectedIcon: Icons.circle,
        ),
      ]);
      // Two places never share one identity.
      await refuses([_places.first, _places.first]);
      // A place without an identity, or without a name, is not a place.
      await refuses([
        _places.first,
        const MentoraBottomNavigationDestination(
          id: '',
          label: 'Consultation',
          icon: Icons.circle_outlined,
          selectedIcon: Icons.circle,
        ),
      ]);
      await refuses([
        _places.first,
        const MentoraBottomNavigationDestination(
          id: 'consultation',
          label: '',
          icon: Icons.circle_outlined,
          selectedIcon: Icons.circle,
        ),
      ]);
      // A structure never guesses where the person is.
      await refuses(_places, selectedDestinationId: 'elsewhere');
    });

    testWidgets('nowhere announced is a legitimate context: nothing is '
        'chosen, and nothing breaks', (tester) async {
      await _pump(tester, _navigation(selectedDestinationId: null));

      expect(tester.takeException(), isNull);
      for (final place in _places) {
        expect(_capsuleColor(_capsule(tester, place.id)), isNull);
      }
    });

    testWidgets('the band is a minimum: at the largest scale the '
        'structure grows, and clips nothing', (tester) async {
      await _pump(tester, _navigation());
      final resting = tester.getSize(find.byType(MentoraBottomNavigation));
      expect(
        resting.height,
        greaterThanOrEqualTo(bottomNavigationTokens.height),
      );

      await _pump(
        tester,
        _navigation(),
        appearance: const AppearanceState(
          fontScale: FontScalePreference.extraLarge,
          readingComfort: ReadingComfortPreference.standard,
        ),
        textScale: 1.3,
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(MentoraBottomNavigation)).height,
        greaterThanOrEqualTo(resting.height),
      );
    });

    testWidgets('the structure holds in the four themes and in both '
        'reading directions', (tester) async {
      for (final variant in ThemeVariantId.values) {
        await _pump(tester, _navigation(), variant: variant);
        expect(tester.takeException(), isNull);
        expect(_capsuleColor(_capsule(tester, 'home')), isNotNull);
      }

      for (final direction in TextDirection.values) {
        await _pump(tester, _navigation(), direction: direction);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('the reading direction places the destinations, and what '
        'happens in them', (tester) async {
      await _pump(tester, _navigation());
      final ltrFirst = tester.getCenter(_destination('home')).dx;
      final ltrBadge = tester.getCenter(find.byType(MentoraBadge)).dx;
      final ltrMark = tester
          .getCenter(
            find.byKey(
              const Key(
                'bottom-navigation-capsule-'
                'notifications',
              ),
            ),
          )
          .dx;

      await _pump(tester, _navigation(), direction: TextDirection.rtl);
      final rtlFirst = tester.getCenter(_destination('home')).dx;
      final rtlBadge = tester.getCenter(find.byType(MentoraBadge)).dx;
      final rtlMark = tester
          .getCenter(
            find.byKey(
              const Key(
                'bottom-navigation-capsule-'
                'notifications',
              ),
            ),
          )
          .dx;

      // The first place follows the reading direction…
      expect(rtlFirst, greaterThan(ltrFirst));
      // …and so does the corner what happens in a place stands in.
      expect(ltrBadge, greaterThan(ltrMark));
      expect(rtlBadge, lessThan(rtlMark));
    });

    testWidgets('every transition comes from the Motion Engine: None '
        'silences it', (tester) async {
      const appearance = AppearanceState();
      final services = await _pump(tester, _navigation());
      expect(
        tester
            .widget<AnimatedContainer>(
              find.byKey(const Key('bottom-navigation-surface')),
            )
            .duration,
        services.get<MotionEngine>().durationFor(
          MotionIntention.montrerLaContinuite,
          appearance,
        ),
      );

      await _pump(
        tester,
        _navigation(),
        appearance: const AppearanceState(motion: MotionPreference.none),
      );
      expect(_capsule(tester, 'home').duration, Duration.zero);
    });

    testWidgets('the structure never takes the focus, and always gives '
        'it back', (tester) async {
      final elsewhere = FocusNode(debugLabel: 'content');
      addTearDown(elsewhere.dispose);

      await _pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Focus(focusNode: elsewhere, child: const SizedBox.shrink()),
            _navigation(),
          ],
        ),
      );

      elsewhere.requestFocus();
      await tester.pumpAndSettle();
      expect(elsewhere.hasPrimaryFocus, isTrue);

      // The structure appearing, and being told where the person is,
      // never moves the focus away from the content.
      await tester.pumpAndSettle();
      expect(elsewhere.hasPrimaryFocus, isTrue);
    });

    testWidgets('outside the Design Kit the structure refuses to build — '
        'fail closed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Align(alignment: Alignment.bottomCenter, child: _navigation()),
        ),
      );
      expect(tester.takeException(), isStateError);
    });
  });

  group('The migration — the Kit owns the bottom navigation', () {
    testWidgets('the application shell shows the official component, and '
        'reports identities to it', (tester) async {
      final services = await _services();
      await tester.pumpWidget(MentoraFoundationApp(services: services));
      await tester.pumpAndSettle();

      expect(find.byType(MentoraBottomNavigation), findsOneWidget);
      final structure = tester.widget<MentoraBottomNavigation>(
        find.byType(MentoraBottomNavigation),
      );
      expect(structure.destinations.length, 5);
      expect(structure.selectedDestinationId, 'home');

      await tester.tap(_destination('account'));
      await tester.pumpAndSettle();

      // The application decided, and the surface followed.
      expect(
        tester
            .widget<MentoraBottomNavigation>(
              find.byType(MentoraBottomNavigation),
            )
            .selectedDestinationId,
        'account',
      );
      expect(find.text('Account'), findsNWidgets(2));
    });

    testWidgets('the shell holds no page and no navigation of its own: '
        'both are Structural Components', (tester) async {
      final services = await _services();
      await tester.pumpWidget(MentoraFoundationApp(services: services));
      await tester.pumpAndSettle();

      expect(find.byType(MentoraPageScaffold), findsOneWidget);
      // The principal level survives a change of surface: it belongs
      // to the working context, never to one page of it.
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      final workspace = tester.widget<MentoraWorkspace>(
        find.byType(MentoraWorkspace),
      );
      expect(workspace.base, isNotNull);
      expect(
        tester
            .widget<MentoraPageScaffold>(find.byType(MentoraPageScaffold))
            .bottomNavigation,
        isNull,
      );
    });

    testWidgets('the working context places the principal level at its '
        'base, across the whole context', (tester) async {
      final services = await _services();
      await tester.pumpWidget(MentoraFoundationApp(services: services));
      await tester.pumpAndSettle();

      final workspace = tester.getRect(find.byType(MentoraWorkspace));
      final structure = tester.getRect(find.byType(MentoraBottomNavigation));
      expect(structure.bottom, workspace.bottom);
      expect(structure.width, workspace.width);
      // The surface stops where the principal level begins.
      expect(
        tester.getRect(find.byType(MentoraPageScaffold)).bottom,
        lessThanOrEqualTo(structure.top),
      );
      expect(
        tester.getRect(find.text('Nothing needs your attention.')).bottom,
        lessThanOrEqualTo(structure.top),
      );
    });

    testWidgets('a page without a principal level adds nothing at its '
        'base', (tester) async {
      await _pump(
        tester,
        const MentoraPageScaffold(
          semanticLabel: 'Consultations',
          content: MentoraText('Contenu', role: MentoraTextRole.body),
        ),
      );

      expect(find.byType(MentoraBottomNavigation), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Governance — the executable scans ship with the component', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    test('no framework bottom navigation survives in the foundation: '
        'Flutter stays a primitive', () {
      final forbidden = <String, RegExp>{
        'BottomNavigationBar': RegExp(
          r'(?<![A-Za-z])BottomNavigationBar(?![A-Za-z])',
        ),
        'BottomNavigationBarItem': RegExp(
          r'(?<![A-Za-z])BottomNavigationBarItem(?![A-Za-z])',
        ),
        'NavigationBar': RegExp(r'(?<![A-Za-z])NavigationBar(?![A-Za-z])'),
        'NavigationDestination': RegExp(
          r'(?<![A-Za-z])NavigationDestination(?![A-Za-z])',
        ),
        'CupertinoTabBar': RegExp(r'(?<![A-Za-z])CupertinoTabBar(?![A-Za-z])'),
        'CupertinoTabScaffold': RegExp(
          r'(?<![A-Za-z])CupertinoTabScaffold(?![A-Za-z])',
        ),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: the principal level is a '
                'MentoraBottomNavigation — never a ${entry.key}',
          );
        }
      }
    });

    test('the application shell owns no official navigation component, '
        'and no position', () {
      final files = dartFilesOf('lib/foundation/navigation');
      expect(files, isNotEmpty);
      final defines = <String, RegExp>{
        'a navigation component of its own': RegExp(
          r'class\s+Mentora\w*(Navigation|Bar|Tabs|Drawer|Rail)\w*',
        ),
        'a destination of its own': RegExp(r'class\s+\w*Destination'),
        'a position': RegExp(
          r'(final\s+int\s|(?<![A-Za-z])int\s+\w*[Ii]ndex|selectedIndex|'
          r'\.indexOf\()',
        ),
        'a framework scaffold': RegExp(r'(?<![A-Za-z])Scaffold\('),
      };
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in defines.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: the shell carries the identities of the '
                'product — never ${entry.key}',
          );
        }
      }
    });

    test('one bottom navigation exists in the product, and it lives in '
        'the Design Kit', () {
      final declarations = <String>[];
      for (final directory in const ['lib/foundation', 'lib/core', 'lib/app']) {
        if (!Directory(directory).existsSync()) continue;
        for (final file in dartFilesOf(directory)) {
          if (RegExp(
            r'class\s+MentoraBottomNavigation(?![A-Za-z])',
          ).hasMatch(file.readAsStringSync())) {
            declarations.add(file.path.replaceAll(r'\', '/'));
          }
        }
      }
      expect(declarations, hasLength(1));
      expect(
        declarations.single,
        contains('design_kit/structure/bottom_navigation/'),
      );
    });

    test('the principal level knows no address, no platform and no '
        'measure of the screen', () {
      final forbidden = <String, RegExp>{
        'an address': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|routeName|pushNamed|push|pop|'
          r'MaterialPageRoute|Uri|deepLink)(?![A-Za-z])',
        ),
        'a route type': RegExp(r'(?<![A-Za-z])Route<'),
        'a platform': RegExp(
          r'(?<![A-Za-z])(Platform|TargetPlatform|defaultTargetPlatform|'
          r'kIsWeb|isAndroid|isIOS)(?![A-Za-z])',
        ),
        'a measure of the screen': RegExp(
          r'(?<![A-Za-z])(MediaQuery|LayoutBuilder|ResponsiveEngine)'
          r'(?![A-Za-z])',
        ),
        'a position': RegExp(
          r'(final\s+int\s|(?<![A-Za-z])int\s+\w*[Ii]ndex|selectedIndex)',
        ),
      };
      final files = dartFilesOf(
        'lib/foundation/design_kit/structure/bottom_navigation',
      );
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

    test('the principal level rebuilds nothing it does not own, reads no '
        'ambient theme and codes no value', () {
      final forbidden = <String, RegExp>{
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
        'its own badge': RegExp(r'(?<![A-Za-z])Badge\('),
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'a coded padding': RegExp(r'EdgeInsets\.\w+\(\s*[0-9]'),
        'a coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'a coded size': RegExp(r'(fontSize:|size:\s*[0-9])'),
        'a coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
      };
      for (final file in dartFilesOf(
        'lib/foundation/design_kit/structure/bottom_navigation',
      )) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: a structure never carries ${entry.key}',
          );
        }
      }
    });

    test('no business domain is named by the principal level', () {
      final business = RegExp(
        r'(?<![A-Za-z])(Wallet|Consultation|Business|Chat|Invoice|Facture|'
        r'Product|Dashboard|Profile|Settings)(?![a-z])',
      );
      for (final file in dartFilesOf(
        'lib/foundation/design_kit/structure/bottom_navigation',
      )) {
        expect(
          business.hasMatch(file.readAsStringSync()),
          isFalse,
          reason: '${file.path}: a structure knows no business',
        );
      }
    });
  });
}
