import 'dart:io';

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
import 'package:mentora/foundation/design_kit/components/input/mentora_input.dart';
import 'package:mentora/foundation/design_kit/components/input/mentora_input_style.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/app_bar/mentora_app_bar.dart';
import 'package:mentora/foundation/design_kit/structure/app_bar/mentora_app_bar_style.dart';
import 'package:mentora/foundation/design_kit/structure/app_bar/mentora_app_bar_theme.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/app_bar_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

void _noop() {}

MentoraAppBar _context({
  MentoraAppBarVariant variant = MentoraAppBarVariant.standard,
  MentoraAppBarController? controller,
  MentoraAppBarScrollBehaviour scrollBehaviour =
      MentoraAppBarScrollBehaviour.pinned,
  MentoraAppBarNavigation? navigation,
  MentoraAvatar? identity,
  String? semanticLabel,
  bool composed = true,
}) {
  return MentoraAppBar(
    variant: variant,
    controller: controller,
    scrollBehaviour: scrollBehaviour,
    semanticLabel: semanticLabel,
    title: 'Consultations',
    subtitle: composed ? 'Aujourd’hui' : null,
    navigation: navigation,
    identity: identity,
    badge: composed
        ? const MentoraBadge(
            variant: MentoraBadgeVariant.information,
            shape: MentoraBadgeShape.pill,
            label: '4',
            semanticLabel: '4 consultations',
          )
        : null,
    actions: composed
        ? [
            MentoraButton(
              label: 'Filtrer',
              onPressed: _noop,
              variant: MentoraButtonVariant.text,
              size: MentoraButtonSize.small,
            ),
          ]
        : const [],
    search: variant == MentoraAppBarVariant.search
        ? const MentoraInput(
            variant: MentoraInputVariant.search,
            placeholder: 'Rechercher',
            semanticLabel: 'Rechercher une consultation',
          )
        : null,
  );
}

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  MentoraAppBar bar, {
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
          // A structure is given to a host exactly as a screen will
          // give it: through the room it reserves.
          child: Scaffold(appBar: bar, body: const SizedBox.shrink()),
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

AnimatedContainer _surfaceOf(WidgetTester tester) {
  return tester.widget<AnimatedContainer>(
    find.byKey(const Key('app-bar-surface')),
  );
}

BoxDecoration _decorationOf(WidgetTester tester) =>
    _surfaceOf(tester).decoration! as BoxDecoration;

void main() {
  group('A context announces where the person is', () {
    testWidgets('it reserves its room without a context, and the host '
        'honours it', (tester) async {
      for (final variant in MentoraAppBarVariant.values) {
        final expected = MentoraAppBarTheme.extentOf(variant).reservedExtent;
        // The extent is a pure Token function: a host reserves the
        // room before any engine is consulted.
        expect(_context(variant: variant).preferredSize.height, expected);

        await _pump(
          tester,
          _context(
            variant: variant,
            controller: variant == MentoraAppBarVariant.search
                ? MentoraAppBarController(MentoraAppBarStatus.searching)
                : null,
          ),
        );
        expect(
          tester.getSize(find.byType(MentoraAppBar)).height,
          expected,
          reason: '${variant.name} must occupy exactly the room it reserved',
        );
      }
    });

    testWidgets('the PLACE is the header — that is how a screen reader '
        'travels, and the acts stay controls of their own', (tester) async {
      final handle = tester.ensureSemantics();

      await _pump(tester, _context());
      // The words the context owns are heard as one place, and that
      // place is what a header navigation lands on.
      final place = tester.getSemantics(find.text('Consultations'));
      expect(place.flagsCollection.isHeader, isTrue);
      expect(place.label, contains('Consultations'));
      expect(place.label, contains('Aujourd’hui'));
      // The act offered from here is never swallowed into the name of
      // the place: it stays a control.
      expect(find.bySemanticsLabel('Filtrer'), findsOneWidget);

      await _pump(
        tester,
        _context(semanticLabel: 'Consultations du jour, 4 à venir'),
      );
      final named = tester.getSemantics(
        find.bySemanticsLabel('Consultations du jour, 4 à venir'),
      );
      expect(named.flagsCollection.isHeader, isTrue);
      expect(named.label, 'Consultations du jour, 4 à venir');
      expect(find.bySemanticsLabel('Filtrer'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a place that cannot be named announces nothing — fail '
        'closed', (tester) async {
      await _pump(tester, const MentoraAppBar(title: ''));
      expect(tester.takeException(), isStateError);
    });

    testWidgets('a context has one start: a way out and an identity '
        'never share it', (tester) async {
      await _pump(
        tester,
        _context(
          navigation: MentoraAppBarNavigation.back(
            label: 'Retour',
            onInvoke: _noop,
          ),
          identity: const MentoraAvatar(
            identity: MentoraAvatarIdentity.user,
            name: 'Awa Mensah',
          ),
        ),
      );
      expect(tester.takeException(), isStateError);
    });

    testWidgets('a searching context without an entry searches nothing '
        '— and a stretch is refused where there is no room to give', (
      tester,
    ) async {
      await _pump(
        tester,
        const MentoraAppBar(
          title: 'Consultations',
          variant: MentoraAppBarVariant.search,
        ),
      );
      expect(tester.takeException(), isStateError);

      await _pump(
        tester,
        _context(scrollBehaviour: MentoraAppBarScrollBehaviour.stretchable),
      );
      expect(tester.takeException(), isStateError);
    });
  });

  group('It composes the official components and redefines none', () {
    testWidgets('the way out, the identity, the state, the acts and the '
        'entry are all owned by their components', (tester) async {
      await _pump(
        tester,
        _context(
          navigation: MentoraAppBarNavigation.close(
            label: 'Fermer',
            onInvoke: _noop,
          ),
        ),
      );
      // The way out and the acts are buttons.
      expect(find.byKey(const Key('app-bar-close')), findsOneWidget);
      expect(find.byType(MentoraButton), findsNWidgets(2));
      expect(find.byType(MentoraBadge), findsOneWidget);

      await _pump(
        tester,
        _context(
          variant: MentoraAppBarVariant.search,
          controller: MentoraAppBarController(MentoraAppBarStatus.searching),
        ),
      );
      expect(find.byType(MentoraInput), findsOneWidget);
      expect(find.text('Consultations'), findsNothing);
    });

    testWidgets('the way out is invoked, and a disabled context offers '
        'nothing at all', (tester) async {
      var left = 0;
      await _pump(
        tester,
        _context(
          navigation: MentoraAppBarNavigation.back(
            label: 'Retour',
            onInvoke: () => left++,
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('app-bar-back')));
      await tester.pump();
      expect(left, 1);

      await _pump(
        tester,
        _context(
          navigation: MentoraAppBarNavigation.back(
            label: 'Retour',
            onInvoke: () => left++,
          ),
          controller: MentoraAppBarController(MentoraAppBarStatus.disabled),
        ),
      );
      expect(find.byType(MentoraBadge), findsNothing);
      await tester.tap(find.byKey(const Key('app-bar-back')));
      await tester.pump();
      expect(left, 1, reason: 'a disabled context offers no act');
    });

    testWidgets('a loading context shows exactly one sober signal', (
      tester,
    ) async {
      await _pump(
        tester,
        _context(
          controller: MentoraAppBarController(MentoraAppBarStatus.loading),
        ),
        settle: false,
      );
      expect(find.byKey(const Key('app-bar-progress')), findsOneWidget);
    });
  });

  group('The scroll is declared, never listened to', () {
    testWidgets('the context expresses the progress the application '
        'announces — it measures nothing itself', (tester) async {
      final controller = MentoraAppBarController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        _context(
          variant: MentoraAppBarVariant.largeTitle,
          scrollBehaviour: MentoraAppBarScrollBehaviour.collapsible,
          controller: controller,
        ),
      );
      // Expanded: the place is announced in full.
      expect(find.byKey(const Key('app-bar-large-title')), findsOneWidget);

      controller.reportProgress(1);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('app-bar-large-title')), findsNothing);
      expect(find.text('Consultations'), findsOneWidget);
      // The room stays the room: the content below never jumps.
      expect(
        tester.getSize(find.byType(MentoraAppBar)).height,
        largeTitleAppBarSpec.reservedExtent,
      );
    });

    testWidgets('a progress outside its official range is refused: the '
        'structure never guesses', (tester) async {
      final controller = MentoraAppBarController();
      addTearDown(controller.dispose);

      expect(() => controller.reportProgress(-0.1), throwsStateError);
      expect(
        () => controller.reportProgress(
          appBarFullOpacity + appBarMaximumStretch + 0.1,
        ),
        throwsStateError,
      );
      controller.reportProgress(appBarFullOpacity + appBarMaximumStretch);
      expect(
        controller.collapseProgress,
        appBarFullOpacity + appBarMaximumStretch,
      );
    });

    testWidgets('a context the content has passed under says so with a '
        'delimitation — never with a shadow it invented', (tester) async {
      final controller = MentoraAppBarController();
      addTearDown(controller.dispose);
      final services = await _pump(tester, _context(controller: controller));
      expect(find.byKey(const Key('app-bar-divider')), findsNothing);

      controller.reportProgress(0.4);
      await tester.pumpAndSettle();
      expect(
        tester.widget<Divider>(find.byKey(const Key('app-bar-divider'))).color,
        services.get<ColorTokenEngine>().colorOf(
          ColorRole.divider,
          ThemeVariantId.light,
        ),
      );
      expect(_decorationOf(tester).boxShadow, isNull);
    });

    testWidgets('only a context that offers more room than it keeps may '
        'collapse', (tester) async {
      expect(canCollapse(MentoraAppBarVariant.largeTitle), isTrue);
      for (final variant in MentoraAppBarVariant.values) {
        if (variant == MentoraAppBarVariant.largeTitle) continue;
        expect(canCollapse(variant), isFalse);
        expect(
          MentoraAppBarTheme.extentOf(variant).reservedExtent,
          MentoraAppBarTheme.extentOf(variant).collapsedExtent,
        );
      }
    });
  });

  group('It travels', () {
    testWidgets('a transparent context rests on nothing — every other '
        'one on the official surface', (tester) async {
      for (final variant in ThemeVariantId.values) {
        final services = await _pump(tester, _context(), variant: variant);
        expect(
          _decorationOf(tester).color,
          services.get<SurfaceTokenEngine>().surfaceOf(
            SurfaceRole.primarySurface,
            variant,
          ),
        );
      }

      await _pump(tester, _context(variant: MentoraAppBarVariant.transparent));
      expect(_decorationOf(tester).color, isNull);
    });

    testWidgets('both directions and every reading comfort are served '
        'without any special handling', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(
          tester,
          _context(
            navigation: MentoraAppBarNavigation.back(
              label: 'رجوع',
              onInvoke: _noop,
            ),
          ),
          direction: direction,
        );
        expect(tester.takeException(), isNull);
        expect(find.text('رجوع'), findsOneWidget);
      }

      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          _context(),
          appearance: AppearanceState(readingComfort: comfort),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('a long title never breaks the structure', (tester) async {
      await _pump(
        tester,
        const MentoraAppBar(
          title:
              'Consultations de suivi avec les experts partenaires du '
              'réseau international',
          variant: MentoraAppBarVariant.compact,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('every transition comes from the Motion Engine: None '
        'silences it', (tester) async {
      const appearance = AppearanceState();
      final services = await _pump(tester, _context());
      expect(
        _surfaceOf(tester).duration,
        services.get<MotionEngine>().durationFor(
          MotionIntention.montrerLaContinuite,
          appearance,
        ),
      );

      await _pump(
        tester,
        _context(),
        appearance: const AppearanceState(motion: MotionPreference.none),
      );
      expect(_surfaceOf(tester).duration, Duration.zero);
    });

    testWidgets('outside the Design Kit the context refuses to build — '
        'fail closed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: MentoraAppBar(title: 'Consultations'),
            body: SizedBox.shrink(),
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

    test('no framework app bar survives in the foundation: Flutter '
        'stays a primitive', () {
      final forbidden = <String, RegExp>{
        'AppBar': RegExp(r'(?<![A-Za-z])AppBar\('),
        'SliverAppBar': RegExp(r'(?<![A-Za-z])SliverAppBar\('),
        'AppBarTheme': RegExp(r'(?<![A-Za-z])AppBarTheme\('),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a context is a MentoraAppBar — never a '
                '${entry.key}',
          );
        }
      }
    });

    test('a Structural Component composes official components, builds '
        'none of what they own, and listens to no scroll', () {
      final rebuilds = <String, RegExp>{
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
        'a coded size': RegExp(r'fontSize:'),
        'a coded weight': RegExp(r'FontWeight\.'),
        // A structure declares how it behaves; it never measures.
        'a scroll it listens to': RegExp(
          r'(?<![A-Za-z])(ScrollController|ScrollNotification|'
          r'NotificationListener)(?![A-Za-z])',
        ),
      };
      final import = RegExp(r"import '[.][.]/[.][.]/([a-z_]+)/");
      const admitted = {
        'components',
        // A structure may compose a Composition Component: an
        // orientation map presents the person's space with the very
        // component that presents an entity.
        'composition',
        // A structure that presents ways to places consumes the ONE
        // navigation vocabulary — a destination is declared once for
        // the whole Kit, never once per structure.
        'navigation',
        'tokens',
        'registry',
        'theme',
        'motion',
        'appearance',
        'accessibility',
      };

      final files = dartFilesOf('lib/foundation/design_kit/structure');
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in rebuilds.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a structure never carries '
                '${entry.key}',
          );
        }
        for (final match in import.allMatches(source)) {
          expect(
            admitted,
            contains(match.group(1)),
            reason:
                '${file.path}: a structure assembles official '
                'components and consumes the Kit — nothing else',
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
