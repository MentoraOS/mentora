import 'dart:io';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/badge/mentora_badge.dart';
import 'package:mentora/foundation/design_kit/components/badge/mentora_badge_style.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/tabs/mentora_tabs.dart';
import 'package:mentora/foundation/design_kit/structure/tabs/mentora_tabs_style.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/tabs_tokens.dart';

const List<MentoraTab> _facets = [
  MentoraTab(
    id: 'overview',
    label: 'Vue d’ensemble',
    icon: Icons.dashboard_outlined,
  ),
  MentoraTab(
    id: 'sessions',
    label: 'Séances',
    badge: MentoraBadge(
      variant: MentoraBadgeVariant.information,
      shape: MentoraBadgeShape.pill,
      label: '3',
      semanticLabel: '3 séances',
    ),
  ),
  MentoraTab(id: 'documents', label: 'Documents', loading: true),
  MentoraTab(id: 'archive', label: 'Archives', enabled: false),
];

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  MentoraTabs tabs, {
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
  TextDirection direction = TextDirection.ltr,
  bool settle = true,
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
            body: Align(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox(width: 600, child: tabs),
            ),
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return services;
}

MentoraTabs _tabs({
  MentoraTabsController? controller,
  List<MentoraTab> facets = _facets,
  ValueChanged<String>? onTabSelected,
  MentoraTabsEmphasis emphasis = MentoraTabsEmphasis.primary,
  MentoraTabsShape shape = MentoraTabsShape.underline,
  MentoraTabsOverflow overflow = MentoraTabsOverflow.scroll,
  bool enabled = true,
}) {
  return MentoraTabs(
    controller: controller ?? MentoraTabsController('overview'),
    tabs: facets,
    emphasis: emphasis,
    shape: shape,
    overflow: overflow,
    enabled: enabled,
    onTabSelected: onTabSelected ?? (_) {},
  );
}

BoxDecoration _decorationOf(WidgetTester tester, String id) {
  return tester
          .widget<AnimatedContainer>(
            find.descendant(
              of: find.byKey(Key('tab-$id')),
              matching: find.byType(AnimatedContainer),
            ),
          )
          .decoration
      as BoxDecoration;
}

void main() {
  group('A facet is an identity, never a position', () {
    testWidgets('the selection travels by identity, and the set only '
        'reports it', (tester) async {
      final controller = MentoraTabsController('overview');
      addTearDown(controller.dispose);
      String? reported;

      await _pump(
        tester,
        _tabs(
          controller: controller,
          onTabSelected: (String id) => reported = id,
        ),
        settle: false,
      );

      await tester.tap(find.byKey(const Key('tab-sessions')));
      await tester.pump();
      expect(reported, 'sessions');
      // The set did NOT change what is shown: it reported, nothing more.
      expect(controller.selectedId, 'overview');

      controller.announceSelection(reported!);
      await tester.pump();
      expect(controller.selectedId, 'sessions');
    });

    testWidgets('a facet announced that the set does not present is '
        'refused — a set never guesses', (tester) async {
      await _pump(
        tester,
        _tabs(controller: MentoraTabsController('elsewhere')),
        settle: false,
      );
      expect(tester.takeException(), isStateError);
    });

    testWidgets('a single facet reveals nothing, two facets never share '
        'one identity, and none is nameless', (tester) async {
      await _pump(
        tester,
        _tabs(
          facets: const [MentoraTab(id: 'overview', label: 'Seule')],
        ),
        settle: false,
      );
      expect(tester.takeException(), isStateError);

      await _pump(
        tester,
        _tabs(
          facets: const [
            MentoraTab(id: 'overview', label: 'Une'),
            MentoraTab(id: 'overview', label: 'Deux'),
          ],
        ),
        settle: false,
      );
      expect(tester.takeException(), isStateError);

      await _pump(
        tester,
        _tabs(
          facets: const [
            MentoraTab(id: 'overview', label: ''),
            MentoraTab(id: 'sessions', label: 'Séances'),
          ],
        ),
        settle: false,
      );
      expect(tester.takeException(), isStateError);
    });
  });

  group('The set organizes one context', () {
    testWidgets('the shown facet wears the emphasis role — the primary '
        'identity, or the second voice', (tester) async {
      for (final pair in const [
        (MentoraTabsEmphasis.primary, ColorRole.primary),
        (MentoraTabsEmphasis.secondary, ColorRole.secondary),
      ]) {
        final services = await _pump(
          tester,
          _tabs(emphasis: pair.$1),
          settle: false,
        );
        final indicator =
            (_decorationOf(tester, 'overview').border! as Border).bottom;
        expect(
          indicator.color,
          services.get<ColorTokenEngine>().colorOf(
            pair.$2,
            ThemeVariantId.light,
          ),
        );
        expect(indicator.width, tabIndicatorThickness);
      }
    });

    testWidgets('each shape draws the chosen facet its own way', (
      tester,
    ) async {
      await _pump(tester, _tabs(), settle: false);
      // Underlined: a line under the facet, and a shared baseline.
      expect(_decorationOf(tester, 'overview').color, isNull);
      expect(find.byKey(const Key('tabs-baseline')), findsOneWidget);

      for (final shape in const [
        MentoraTabsShape.segmented,
        MentoraTabsShape.contained,
      ]) {
        await _pump(tester, _tabs(shape: shape), settle: false);
        expect(_decorationOf(tester, 'overview').color, isNotNull);
        expect(_decorationOf(tester, 'overview').border, isNull);
        expect(find.byKey(const Key('tabs-baseline')), findsNothing);
      }
    });

    testWidgets('the overflow is declared: the facets share the room, '
        'or keep it and the set scrolls', (tester) async {
      await _pump(tester, _tabs(), settle: false);
      expect(find.byKey(const Key('tabs-scroll')), findsOneWidget);

      await _pump(
        tester,
        _tabs(overflow: MentoraTabsOverflow.fit),
        settle: false,
      );
      expect(find.byKey(const Key('tabs-scroll')), findsNothing);
      // Sharing the room means every facet gets the same width.
      final widths = _facets
          .map((facet) => tester.getSize(find.byKey(Key('tab-${facet.id}'))))
          .map((size) => size.width)
          .toSet();
      expect(widths.length, 1);
    });

    testWidgets('a facet still being prepared shows one sober signal '
        'and is never chosen', (tester) async {
      var reported = 0;
      await _pump(
        tester,
        _tabs(onTabSelected: (_) => reported++),
        settle: false,
      );

      expect(
        find.descendant(
          of: find.byKey(const Key('tab-documents')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('tab-documents')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(reported, 0);
    });

    testWidgets('a facet that cannot be shown is expressed, and never '
        'reported', (tester) async {
      var reported = 0;
      final services = await _pump(
        tester,
        _tabs(onTabSelected: (_) => reported++),
        settle: false,
      );

      final words = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const Key('tab-archive')),
          matching: find.byType(Text),
        ),
      );
      expect(
        words.style?.color,
        services
            .get<ColorTokenEngine>()
            .colorOf(ColorRole.unavailable, ThemeVariantId.light),
      );

      await tester.tap(
        find.byKey(const Key('tab-archive')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(reported, 0);
    });

    testWidgets('a set the application put to rest is veiled and '
        'reports nothing', (tester) async {
      var reported = 0;
      await _pump(
        tester,
        _tabs(enabled: false, onTabSelected: (_) => reported++),
        settle: false,
      );

      expect(
        tester
            .widget<Opacity>(find.byKey(const Key('tabs-presence')))
            .opacity,
        tabsDisabledVeilOpacity,
      );
      await tester.tap(
        find.byKey(const Key('tab-sessions')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(reported, 0);
    });
  });

  group('It is reachable, and it travels', () {
    testWidgets('every facet is a reachable target and a control of its '
        'own', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _tabs(), settle: false);

      for (final facet in _facets) {
        expect(
          tester.getSize(find.byKey(Key('tab-${facet.id}'))).height,
          greaterThanOrEqualTo(48),
        );
        expect(
          tester.getSize(find.byKey(Key('tab-${facet.id}'))).width,
          greaterThanOrEqualTo(tabMinimumWidth),
        );
      }

      final shown = tester.getSemantics(find.byKey(const Key('tab-overview')));
      expect(shown.label, 'Vue d’ensemble');
      expect(shown.flagsCollection.isButton, isTrue);
      expect(shown.flagsCollection.isSelected, Tristate.isTrue);
      handle.dispose();
    });

    testWidgets('the arrow keys travel between facets in the reading '
        'direction — the framework traversal, so RTL is right by '
        'construction', (tester) async {
      await _pump(tester, _tabs(), settle: false);

      // A facet still being prepared shows a signal that never rests:
      // this set is pumped, never settled.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(tester.takeException(), isNull);
      // A facet holds the focus, and the focus role expresses it.
      expect(FocusManager.instance.primaryFocus, isNotNull);
    });

    testWidgets('the four theme variants, both directions and every '
        'reading comfort are served without special handling', (
      tester,
    ) async {
      for (final variant in ThemeVariantId.values) {
        final services = await _pump(
          tester,
          _tabs(),
          variant: variant,
          settle: false,
        );
        expect(
          (_decorationOf(tester, 'overview').border! as Border).bottom.color,
          services.get<ColorTokenEngine>().colorOf(ColorRole.primary, variant),
        );
      }

      for (final direction in TextDirection.values) {
        await _pump(tester, _tabs(), direction: direction, settle: false);
        expect(tester.takeException(), isNull);
        expect(find.text('Séances'), findsOneWidget);
      }

      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          _tabs(),
          appearance: AppearanceState(readingComfort: comfort),
          settle: false,
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('a long name never breaks the set', (tester) async {
      await _pump(
        tester,
        _tabs(
          facets: const [
            MentoraTab(
              id: 'overview',
              label: 'Vue d’ensemble des consultations et des documents '
                  'partagés avec les experts partenaires',
            ),
            MentoraTab(id: 'sessions', label: 'Séances'),
          ],
        ),
        settle: false,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('every transition comes from the Motion Engine: None '
        'silences it', (tester) async {
      const appearance = AppearanceState();
      final services = await _pump(tester, _tabs(), settle: false);
      expect(
        tester
            .widget<AnimatedContainer>(find.byKey(const Key('tabs-surface')))
            .duration,
        services
            .get<MotionEngine>()
            .durationFor(MotionIntention.montrerLaContinuite, appearance),
      );

      await _pump(
        tester,
        _tabs(),
        appearance: const AppearanceState(motion: MotionPreference.none),
        settle: false,
      );
      expect(
        tester
            .widget<AnimatedContainer>(find.byKey(const Key('tabs-surface')))
            .duration,
        Duration.zero,
      );
    });

    testWidgets('outside the Design Kit the set refuses to build — fail '
        'closed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MentoraTabs(
              controller: MentoraTabsController('overview'),
              tabs: _facets,
              onTabSelected: (_) {},
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

    test('no framework tab widget or controller survives in the '
        'foundation: Flutter stays a primitive', () {
      final forbidden = <String, RegExp>{
        'TabBar': RegExp(r'(?<![A-Za-z])TabBar(?![A-Za-z])'),
        'TabBarView': RegExp(r'(?<![A-Za-z])TabBarView(?![A-Za-z])'),
        'Tab': RegExp(r'(?<![A-Za-z])Tab\('),
        'TabController': RegExp(r'(?<![A-Za-z])TabController(?![A-Za-z])'),
        'DefaultTabController': RegExp(
          r'(?<![A-Za-z])DefaultTabController(?![A-Za-z])',
        ),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a facet is a MentoraTab — never a '
                '${entry.key}',
          );
        }
      }
    });

    test('no structure carries a position: identities travel, indexes '
        'do not exist', () {
      final positions = <String, RegExp>{
        'a position field': RegExp(r'final\s+int\s'),
        'a position parameter': RegExp(r'(?<![A-Za-z])int\s+\w*[Ii]ndex'),
        'a lookup by position': RegExp(r'\.indexOf\('),
        'a selected position': RegExp(r'selectedIndex'),
      };
      final files = dartFilesOf('lib/foundation/design_kit/structure');
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in positions.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: ${entry.key} — a place and a facet are '
                'identities, never positions',
          );
        }
      }
    });

    test('a set organizes one context: it carries no identity and no '
        'way out — those belong to the other structures', () {
      for (final file in dartFilesOf(
        'lib/foundation/design_kit/structure/tabs',
      )) {
        final source = file.readAsStringSync();
        for (final forbidden in const [
          'components/avatar/',
          'MentoraAvatar',
          'navigation',
        ]) {
          expect(
            source.contains(forbidden),
            isFalse,
            reason:
                '${file.path}: tabs organize a context — they never '
                'navigate between modules ($forbidden)',
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
