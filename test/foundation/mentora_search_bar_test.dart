import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/input/mentora_input.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/search_bar/mentora_search_bar.dart';
import 'package:mentora/foundation/design_kit/structure/search_bar/mentora_search_bar_style.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/search_bar_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

const List<MentoraSearchSuggestion> _aids = [
  MentoraSearchSuggestion(
    id: 'awa',
    label: 'Awa Mensah',
    supporting: 'Experte — Nutrition',
    icon: Icons.person_outline,
  ),
  MentoraSearchSuggestion(id: 'sessions', label: 'Séances de la semaine'),
];

void _noop() {}

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  MentoraSearchBar bar, {
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
              child: SizedBox(width: 600, child: bar),
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

MentoraSearchBar _bar({
  MentoraSearchController? controller,
  ValueChanged<MentoraSearchQuery>? onQueryChanged,
  ValueChanged<String>? onSuggestionChosen,
  MentoraSearchBarVariant variant = MentoraSearchBarVariant.standard,
  String? clearLabel = 'Effacer',
  MentoraSearchAffordance? voice,
  MentoraSearchAffordance? history,
  bool enabled = true,
  String placeholder = 'Rechercher',
  String semanticLabel = 'Rechercher dans Mentora',
}) {
  return MentoraSearchBar(
    controller: controller ?? MentoraSearchController(),
    variant: variant,
    enabled: enabled,
    placeholder: placeholder,
    semanticLabel: semanticLabel,
    clearLabel: clearLabel,
    voice: voice,
    history: history,
    onSuggestionChosen: onSuggestionChosen,
    onQueryChanged: onQueryChanged ?? (_) {},
  );
}

BoxDecoration _decorationOf(WidgetTester tester) {
  return tester
          .widget<AnimatedContainer>(find.byKey(const Key('search-surface')))
          .decoration
      as BoxDecoration;
}

void main() {
  group('A bar carries an intention — it never seeks', () {
    testWidgets('what is written is reported, and nothing changes until '
        'the application acknowledges it', (tester) async {
      final controller = MentoraSearchController();
      addTearDown(controller.dispose);
      MentoraSearchQuery? reported;

      await _pump(
        tester,
        _bar(
          controller: controller,
          onQueryChanged: (query) => reported = query,
        ),
      );

      await tester.enterText(find.byType(TextField), 'nutrition');
      await tester.pump();

      expect(reported, const MentoraSearchQuery('nutrition'));
      // The bar sought nothing and acknowledged nothing by itself.
      expect(controller.query, MentoraSearchQuery.empty);
      expect(controller.phase, MentoraSearchPhase.idle);

      controller.announceQuery(reported!);
      await tester.pump();
      expect(controller.query.text, 'nutrition');
    });

    testWidgets('an acknowledged intention is what the field shows', (
      tester,
    ) async {
      final controller = MentoraSearchController();
      addTearDown(controller.dispose);
      await _pump(tester, _bar(controller: controller));

      controller.announceQuery(const MentoraSearchQuery('consultations'));
      await tester.pump();
      expect(find.text('consultations'), findsOneWidget);
    });

    testWidgets('emptying the intention is an intention like any other: '
        'it is reported, never applied', (tester) async {
      final controller = MentoraSearchController(
        const MentoraSearchQuery('nutrition'),
      );
      addTearDown(controller.dispose);
      MentoraSearchQuery? reported;

      await _pump(
        tester,
        _bar(
          controller: controller,
          onQueryChanged: (query) => reported = query,
        ),
      );

      await tester.tap(find.byKey(const Key('search-clear')));
      await tester.pump();
      expect(reported, MentoraSearchQuery.empty);
      expect(controller.query.text, 'nutrition');
    });

    testWidgets('the act that empties is offered only when it is named, '
        'and only when there is something to empty', (tester) async {
      await _pump(tester, _bar(clearLabel: null));
      expect(find.byKey(const Key('search-clear')), findsNothing);

      await _pump(tester, _bar());
      expect(find.byKey(const Key('search-clear')), findsNothing);

      await _pump(
        tester,
        _bar(
          controller: MentoraSearchController(
            const MentoraSearchQuery('nutrition'),
          ),
        ),
      );
      expect(find.byKey(const Key('search-clear')), findsOneWidget);
    });

    testWidgets('a bar that invites nothing is refused — fail closed', (
      tester,
    ) async {
      await _pump(tester, _bar(placeholder: ''));
      expect(tester.takeException(), isStateError);

      await _pump(tester, _bar(semanticLabel: ''));
      expect(tester.takeException(), isStateError);
    });
  });

  group('An aid is never a search, and never a way somewhere', () {
    testWidgets('aids are published by the application, and choosing '
        'one is reported — never performed', (tester) async {
      final controller = MentoraSearchController()..publishSuggestions(_aids);
      addTearDown(controller.dispose);
      String? chosen;

      await _pump(
        tester,
        _bar(
          controller: controller,
          onSuggestionChosen: (id) => chosen = id,
        ),
      );

      expect(find.text('Awa Mensah'), findsOneWidget);
      expect(find.text('Experte — Nutrition'), findsOneWidget);

      await tester.tap(find.byKey(const Key('search-suggestion-awa')));
      await tester.pump();

      expect(chosen, 'awa');
      // Choosing an aid changed neither the intention nor the phase:
      // the application decides what it means.
      expect(controller.query, MentoraSearchQuery.empty);
      expect(controller.phase, MentoraSearchPhase.idle);
    });

    testWidgets('every aid is a reachable target and a control of its '
        'own', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = MentoraSearchController()..publishSuggestions(_aids);
      addTearDown(controller.dispose);

      await _pump(
        tester,
        _bar(controller: controller, onSuggestionChosen: (_) {}),
      );

      for (final aid in _aids) {
        expect(
          tester
              .getSize(find.byKey(Key('search-suggestion-${aid.id}')))
              .height,
          greaterThanOrEqualTo(48),
        );
      }
      final node = tester.getSemantics(
        find.byKey(const Key('search-suggestion-awa')),
      );
      expect(node.label, 'Awa Mensah');
      expect(node.flagsCollection.isButton, isTrue);
      handle.dispose();
    });

    testWidgets('with no aid published, none is shown', (tester) async {
      await _pump(tester, _bar());
      expect(find.byKey(const Key('search-suggestion-awa')), findsNothing);
    });
  });

  group('The application announces what it is doing', () {
    testWidgets('seeking and gathering are two different facts, and '
        'both show one sober signal', (tester) async {
      for (final phase in const [
        MentoraSearchPhase.searching,
        MentoraSearchPhase.loading,
      ]) {
        final controller = MentoraSearchController()..announcePhase(phase);
        addTearDown(controller.dispose);
        await _pump(tester, _bar(controller: controller), settle: false);
        expect(find.byKey(const Key('search-progress')), findsOneWidget);
      }

      final calm = MentoraSearchController();
      addTearDown(calm.dispose);
      await _pump(tester, _bar(controller: calm));
      expect(find.byKey(const Key('search-progress')), findsNothing);
    });

    testWidgets('a refused attempt is expressed by the critical role', (
      tester,
    ) async {
      final controller = MentoraSearchController()
        ..announcePhase(MentoraSearchPhase.error);
      addTearDown(controller.dispose);
      final services = await _pump(tester, _bar(controller: controller));

      final mark = tester.widget<Icon>(
        find
            .descendant(
              of: find.byKey(const Key('search-surface')),
              matching: find.byType(Icon),
            )
            .first,
      );
      expect(
        mark.color,
        services
            .get<ColorTokenEngine>()
            .colorOf(ColorRole.critical, ThemeVariantId.light),
      );
    });

    testWidgets('a bar the application put to rest is veiled and takes '
        'nothing', (tester) async {
      var reported = 0;
      await _pump(
        tester,
        _bar(
          enabled: false,
          controller: MentoraSearchController(
            const MentoraSearchQuery('nutrition'),
          ),
          onQueryChanged: (_) => reported++,
        ),
      );

      expect(
        tester
            .widget<Opacity>(find.byKey(const Key('search-presence')))
            .opacity,
        searchBarDisabledVeilOpacity,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).enabled,
        isFalse,
      );
      expect(reported, 0);
    });
  });

  group('It composes, and it travels', () {
    testWidgets('the entry belongs to the Input, and the acts to the '
        'Button', (tester) async {
      await _pump(
        tester,
        _bar(
          controller: MentoraSearchController(
            const MentoraSearchQuery('nutrition'),
          ),
          voice: MentoraSearchAffordance(label: 'Dicter', onInvoke: _noop),
          history: MentoraSearchAffordance(
            label: 'Historique',
            onInvoke: _noop,
          ),
        ),
      );

      expect(find.byType(MentoraInput), findsOneWidget);
      // Clear, voice and history: three named acts, none performed here.
      expect(find.byType(MentoraButton), findsNWidgets(3));
      expect(find.byKey(const Key('search-voice')), findsOneWidget);
      expect(find.byKey(const Key('search-history')), findsOneWidget);
    });

    testWidgets('a prepared act is offered only when it is named', (
      tester,
    ) async {
      await _pump(tester, _bar());
      expect(find.byKey(const Key('search-voice')), findsNothing);
      expect(find.byKey(const Key('search-history')), findsNothing);
    });

    testWidgets('every variant is served by its Token spec', (tester) async {
      for (final variant in MentoraSearchBarVariant.values) {
        final services = await _pump(tester, _bar(variant: variant));
        final presentation = specOf(variant);
        final decoration = _decorationOf(tester);

        expect(
          decoration.borderRadius,
          BorderRadius.circular(presentation.radius),
        );
        expect(
          decoration.color,
          presentation.hasGround
              ? services.get<SurfaceTokenEngine>().surfaceOf(
                  SurfaceRole.secondarySurface,
                  ThemeVariantId.light,
                )
              : isNull,
        );
        expect(
          decoration.border,
          presentation.hasBorder ? isNotNull : isNull,
        );
        expect(
          tester.getSize(find.byKey(const Key('search-surface'))).height,
          greaterThanOrEqualTo(48),
        );
      }
    });

    testWidgets('the four theme variants, both directions and a long '
        'intention are served without special handling', (tester) async {
      for (final variant in ThemeVariantId.values) {
        final services = await _pump(tester, _bar(), variant: variant);
        expect(
          _decorationOf(tester).color,
          services.get<SurfaceTokenEngine>().surfaceOf(
            SurfaceRole.secondarySurface,
            variant,
          ),
        );
      }

      for (final direction in TextDirection.values) {
        await _pump(tester, _bar(), direction: direction);
        await tester.enterText(find.byType(TextField), 'استشارة');
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('استشارة'), findsOneWidget);
      }

      await _pump(
        tester,
        _bar(
          controller: MentoraSearchController(
            const MentoraSearchQuery(
              'consultations de suivi avec les experts partenaires du '
              'réseau international',
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('every transition comes from the Motion Engine: None '
        'silences it', (tester) async {
      const appearance = AppearanceState();
      final services = await _pump(tester, _bar());
      AnimatedContainer surface() => tester.widget<AnimatedContainer>(
        find.byKey(const Key('search-surface')),
      );
      expect(
        surface().duration,
        services
            .get<MotionEngine>()
            .durationFor(MotionIntention.accompagner, appearance),
      );

      await _pump(
        tester,
        _bar(),
        appearance: const AppearanceState(motion: MotionPreference.none),
      );
      expect(surface().duration, Duration.zero);
    });

    testWidgets('outside the Design Kit the bar refuses to build — fail '
        'closed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MentoraSearchBar(
              controller: MentoraSearchController(),
              placeholder: 'Rechercher',
              semanticLabel: 'Rechercher',
              onQueryChanged: (_) {},
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

    test('no framework search widget survives in the foundation: '
        'Flutter stays a primitive', () {
      final forbidden = <String, RegExp>{
        'SearchBar': RegExp(r'(?<![A-Za-z])SearchBar(?![A-Za-z])'),
        'SearchAnchor': RegExp(r'(?<![A-Za-z])SearchAnchor(?![A-Za-z])'),
        'SearchController': RegExp(
          r'(?<![A-Za-z])SearchController(?![A-Za-z])',
        ),
        'SearchDelegate': RegExp(r'(?<![A-Za-z])SearchDelegate(?![A-Za-z])'),
        'Autocomplete': RegExp(r'(?<![A-Za-z])Autocomplete(?![A-Za-z])'),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: an intention is a MentoraSearchBar — '
                'never a ${entry.key}',
          );
        }
      }
    });

    test('a structure never interprets, never selects and never speaks '
        'to a network', () {
      // Structural, never lexical: these are identifiers of the code.
      final forbidden = <String, RegExp>{
        'an interpretation': RegExp(
          r'(?<![A-Za-z])(RegExp|toLowerCase|toUpperCase|startsWith|'
          r'compareTo)(?![A-Za-z])',
        ),
        // Verifying a contract with a predicate is not selecting
        // data: what is forbidden is choosing or ordering what to
        // show — that belongs to the business layers.
        'a selection of data': RegExp(
          r'\.(where|firstWhere|lastWhere|singleWhere|sort|reduce|fold)\(',
        ),
        'a network call': RegExp(
          r'(?<![A-Za-z])(http|Uri|HttpClient|WebSocket|Firestore|'
          r'FirebaseFirestore)(?![A-Za-z])',
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
                'the data, the results and the engines belong to the '
                'business layers',
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
