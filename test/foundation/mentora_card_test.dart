import 'dart:io';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card_style.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/card_tokens.dart';

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget card, {
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
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
        child: Scaffold(body: Center(child: card)),
      ),
    ),
  );
  // The element tree survives successive pumps: settle so the state
  // transition (an implicit animation) reaches its resting values.
  await tester.pumpAndSettle();
  return services;
}

AnimatedContainer _container(WidgetTester tester) {
  return tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(MentoraCard),
      matching: find.byType(AnimatedContainer),
    ),
  );
}

BoxDecoration _decoration(WidgetTester tester) {
  return _container(tester).decoration! as BoxDecoration;
}

void main() {
  testWidgets('a card contains what it is given — it invents no '
      'content', (tester) async {
    await _pump(tester, const MentoraCard(child: Text('Consultation')));

    expect(
      find.descendant(
        of: find.byType(MentoraCard),
        matching: find.text('Consultation'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('every variant resolves its official surfaces and '
      'delimitations — nothing else', (tester) async {
    Future<void> check(
      MentoraCardVariant variant,
      void Function(
        ColorTokenEngine colors,
        SurfaceTokenEngine surfaces,
        BoxDecoration decoration,
      )
      verify,
    ) async {
      final services = await _pump(
        tester,
        MentoraCard(
          variant: variant,
          onTap: variant == MentoraCardVariant.interactive ? () {} : null,
          child: const Text('contenu'),
        ),
      );
      verify(
        services.get<ColorTokenEngine>(),
        services.get<SurfaceTokenEngine>(),
        _decoration(tester),
      );
    }

    Color role(ColorTokenEngine colors, ColorRole r) =>
        colors.colorOf(r, ThemeVariantId.light);
    Color surface(SurfaceTokenEngine surfaces, SurfaceRole r) =>
        surfaces.surfaceOf(r, ThemeVariantId.light);

    await check(MentoraCardVariant.surface, (colors, surfaces, decoration) {
      expect(decoration.color, surface(surfaces, SurfaceRole.primarySurface));
      expect(decoration.border, isNull);
      expect(decoration.boxShadow, isNull);
    });
    await check(MentoraCardVariant.outlined, (colors, surfaces, decoration) {
      expect(decoration.color, surface(surfaces, SurfaceRole.primarySurface));
      expect(decoration.border?.top.color, role(colors, ColorRole.outline));
      expect(decoration.boxShadow, isNull);
    });
    await check(MentoraCardVariant.elevated, (colors, surfaces, decoration) {
      expect(decoration.color, surface(surfaces, SurfaceRole.primarySurface));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.single.blurRadius, cardShadow.blurRadius);
    });
    await check(MentoraCardVariant.interactive, (colors, surfaces, decoration) {
      expect(decoration.color, surface(surfaces, SurfaceRole.primarySurface));
      expect(decoration.border?.top.color, role(colors, ColorRole.outline));
    });
    await check(MentoraCardVariant.selected, (colors, surfaces, decoration) {
      expect(decoration.color, role(colors, ColorRole.highlight));
      expect(decoration.border?.top.color, role(colors, ColorRole.selection));
    });
    await check(MentoraCardVariant.protected, (colors, surfaces, decoration) {
      expect(decoration.color, surface(surfaces, SurfaceRole.protectedSurface));
      expect(decoration.border?.top.color, role(colors, ColorRole.attention));
    });
  });

  testWidgets('a card never carries an elevation MEANING: at high '
      'contrast the depth is delimited, never shadowed', (tester) async {
    for (final variant in const [
      ThemeVariantId.lightHighContrast,
      ThemeVariantId.darkHighContrast,
    ]) {
      final services = await _pump(
        tester,
        const MentoraCard(
          variant: MentoraCardVariant.elevated,
          child: Text('contenu'),
        ),
        variant: variant,
      );
      final decoration = _decoration(tester);
      expect(
        decoration.boxShadow,
        isNull,
        reason: 'a soft shadow is unreliable at high contrast',
      );
      expect(
        decoration.border?.top.color,
        services.get<ColorTokenEngine>().colorOf(ColorRole.outline, variant),
      );
    }
  });

  testWidgets('the inner breathing is a spacing RELATION chosen by the '
      'Density preference — never a coded distance', (tester) async {
    final spacings = <DensityPreference, double>{};
    for (final density in DensityPreference.values) {
      final services = await _pump(
        tester,
        const MentoraCard(child: Text('contenu', key: Key('inner'))),
        appearance: AppearanceState(density: density),
      );
      final padding = tester.widget<Padding>(
        find
            .ancestor(
              of: find.byKey(const Key('inner')),
              matching: find.byType(Padding),
            )
            .first,
      );
      final resolved = padding.padding.resolve(TextDirection.ltr);
      final engine = services.get<SpacingTokenEngine>();
      spacings[density] = resolved.left;
      expect(
        resolved.left,
        anyOf(SpacingRelation.values.map(engine.spaceOf).map(equals).toList()),
        reason: 'the padding is always a relation served by the engine',
      );
    }
    // Three preferences, three distinct breathings — the preference is
    // honored, never ignored (GE-16).
    expect(spacings.values.toSet().length, DensityPreference.values.length);
  });

  testWidgets('the tap performs the act — once per tap', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      MentoraCard(
        variant: MentoraCardVariant.interactive,
        onTap: () => taps++,
        child: const Text('ouvrir'),
      ),
    );

    await tester.tap(find.byType(MentoraCard));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('a container that does not invite is not a target: no '
      'minimum extent is imposed on it', (tester) async {
    await _pump(tester, const MentoraCard(child: SizedBox.shrink()));
    expect(_container(tester).constraints, const BoxConstraints());

    var taps = 0;
    await _pump(
      tester,
      MentoraCard(
        variant: MentoraCardVariant.interactive,
        onTap: () => taps++,
        child: const SizedBox.shrink(),
      ),
    );
    final size = tester.getSize(find.byType(MentoraCard));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(size.width, greaterThanOrEqualTo(48));
  });

  testWidgets('an interactive card without an act is refused — fail '
      'closed', (tester) async {
    await _pump(
      tester,
      const MentoraCard(
        variant: MentoraCardVariant.interactive,
        child: Text('vide'),
      ),
    );
    expect(tester.takeException(), isStateError);
  });

  testWidgets('disabled is stated, never hidden: the veil is official '
      'and the act is unreachable', (tester) async {
    var taps = 0;
    final services = await _pump(
      tester,
      MentoraCard(
        variant: MentoraCardVariant.outlined,
        enabled: false,
        onTap: () => taps++,
        child: const Text('contenu'),
      ),
    );

    final opacity = tester.widget<Opacity>(
      find
          .descendant(
            of: find.byType(MentoraCard),
            matching: find.byType(Opacity),
          )
          .first,
    );
    expect(opacity.opacity, cardDisabledVeilOpacity);
    expect(find.text('contenu'), findsOneWidget);
    expect(
      _decoration(tester).color,
      services.get<SurfaceTokenEngine>().surfaceOf(
        SurfaceRole.secondarySurface,
        ThemeVariantId.light,
      ),
    );

    await tester.tap(find.byType(MentoraCard));
    await tester.pump();
    expect(taps, 0);
  });

  testWidgets('loading rests on the calm surface, blocks the act and '
      'invents nothing to fill the wait', (tester) async {
    var taps = 0;
    final controller = MentoraCardController();
    addTearDown(controller.dispose);
    final services = await _pump(
      tester,
      MentoraCard(
        variant: MentoraCardVariant.interactive,
        controller: controller,
        onTap: () => taps++,
        child: const Text('contenu'),
      ),
    );

    controller.beginLoading();
    await tester.pumpAndSettle();

    expect(
      _decoration(tester).color,
      services.get<SurfaceTokenEngine>().surfaceOf(
        SurfaceRole.secondarySurface,
        ThemeVariantId.light,
      ),
    );
    // The container never substitutes a spinner for the content it
    // was given: the application owns what is displayed.
    expect(find.text('contenu'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.byType(MentoraCard));
    await tester.pump();
    expect(taps, 0, reason: 'a pending content is never acted upon');
  });

  testWidgets('error delimits with the critical role and still allows '
      'the act — trying again is never blocked', (tester) async {
    var taps = 0;
    final controller = MentoraCardController();
    addTearDown(controller.dispose);
    final services = await _pump(
      tester,
      MentoraCard(
        variant: MentoraCardVariant.interactive,
        controller: controller,
        onTap: () => taps++,
        child: const Text('contenu'),
      ),
    );

    controller.showError();
    await tester.pumpAndSettle();
    expect(
      _decoration(tester).border?.top.color,
      services.get<ColorTokenEngine>().colorOf(
        ColorRole.critical,
        ThemeVariantId.light,
      ),
    );

    await tester.tap(find.byType(MentoraCard));
    await tester.pump();
    expect(taps, 1);

    controller.reset();
    await tester.pumpAndSettle();
    expect(
      _decoration(tester).border?.top.color,
      services.get<ColorTokenEngine>().colorOf(
        ColorRole.outline,
        ThemeVariantId.light,
      ),
    );
  });

  testWidgets('every duration comes from the Motion Engine: None '
      'silences the transition', (tester) async {
    await _pump(
      tester,
      const MentoraCard(child: Text('contenu')),
      appearance: const AppearanceState(motion: MotionPreference.none),
    );
    expect(_container(tester).duration, Duration.zero);

    const appearance = AppearanceState();
    final services = await _pump(
      tester,
      const MentoraCard(child: Text('contenu')),
    );
    expect(
      _container(tester).duration,
      services.get<MotionEngine>().durationFor(
        MotionIntention.accompagner,
        appearance,
      ),
    );
  });

  testWidgets('the four theme variants serve the same roles — meaning '
      'never changes with appearance', (tester) async {
    for (final variant in ThemeVariantId.values) {
      final services = await _pump(
        tester,
        const MentoraCard(
          variant: MentoraCardVariant.selected,
          child: Text('contenu'),
        ),
        variant: variant,
      );
      expect(
        _decoration(tester).color,
        services.get<ColorTokenEngine>().colorOf(ColorRole.highlight, variant),
      );
    }
  });

  testWidgets('keyboard focus rings with the focus role and Enter '
      'performs the act', (tester) async {
    var taps = 0;
    final services = await _pump(
      tester,
      MentoraCard(
        variant: MentoraCardVariant.interactive,
        onTap: () => taps++,
        child: const Text('ouvrir'),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    final border = _decoration(tester).border?.top;
    expect(
      border?.color,
      services.get<ColorTokenEngine>().colorOf(
        ColorRole.focus,
        ThemeVariantId.light,
      ),
    );
    expect(border?.width, cardFocusRingWidth);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('the card announces itself as a container — a button '
      'only when it invites, selected only when it carries the '
      'selection', (tester) async {
    final handle = tester.ensureSemantics();

    await _pump(
      tester,
      const MentoraCard(semanticLabel: 'Consultation', child: Text('11h')),
    );
    final plain = tester.getSemantics(find.byType(MentoraCard));
    expect(plain.label, contains('Consultation'));
    expect(plain.flagsCollection.isButton, isFalse);
    expect(plain.flagsCollection.isSelected, Tristate.isFalse);

    await _pump(
      tester,
      MentoraCard(
        variant: MentoraCardVariant.selected,
        semanticLabel: 'Consultation',
        onTap: () {},
        child: const Text('11h'),
      ),
    );
    final selected = tester.getSemantics(find.byType(MentoraCard));
    expect(selected.flagsCollection.isButton, isTrue);
    expect(selected.flagsCollection.isSelected, Tristate.isTrue);
    expect(selected.flagsCollection.isEnabled, Tristate.isTrue);

    handle.dispose();
  });

  testWidgets('outside the Design Kit the card refuses to build — fail '
      'closed', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MentoraCard(child: Text('contenu'))),
      ),
    );
    expect(tester.takeException(), isStateError);
  });

  group('Governance — the executable scans ship with the component', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    test('no Material Card survives anywhere in the foundation', () {
      final material = RegExp(r'(?<![A-Za-z])Card\(');
      for (final file in dartFilesOf('lib/foundation')) {
        final normalized = file.path.replaceAll('\\', '/');
        if (normalized.contains('components/card/')) continue;
        expect(
          material.hasMatch(file.readAsStringSync()),
          isFalse,
          reason:
              '${file.path}: only MentoraCard exists — never a Material '
              'Card, never a Container decorated as one',
        );
      }
    });

    test('no form, depth or breathing is ever coded outside the tokens '
        'layer', () {
      final coded = <String, RegExp>{
        'coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'coded padding': RegExp(r'EdgeInsets\.\w+\(\s*[0-9]'),
        'coded elevation': RegExp(r'elevation:\s*[0-9]'),
        'coded shadow': RegExp(r'BoxShadow\(\s*(?!\))'),
        'coded opacity': RegExp(r'opacity:\s*[0-9]'),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final normalized = file.path.replaceAll('\\', '/');
        if (normalized.contains('design_kit/tokens/')) continue;
        final source = file.readAsStringSync();
        for (final entry in coded.entries) {
          if (entry.key == 'coded shadow' &&
              normalized.contains('components/card/mentora_card_theme')) {
            // The adapter composes the shadow FROM the Tokens: its
            // blur, offset, spread and opacity are all served.
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

    test('the components speak roles through the scope — never values, '
        'never the raw sets, never the container', () {
      final files = dartFilesOf('lib/foundation/design_kit/components');
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final forbidden in const [
          'Color(0x',
          'Colors.',
          'Duration(milliseconds',
          'fontSize:',
          'FontWeight.w',
          'tokens/design_tokens.dart',
          'core/di/',
          'foundation_services',
        ]) {
          expect(
            source.contains(forbidden),
            isFalse,
            reason: '${file.path}: a component never carries $forbidden',
          );
        }
      }
    });

    test('every component of every family is catalogued in the living '
        'playground', () {
      final gallery = File(
        'lib/foundation/playground/playground_galleries.dart',
      ).readAsStringSync();
      final mounted = File(
        'lib/foundation/playground/playground_app.dart',
      ).readAsStringSync();
      // Four families now: the Core Components, the Composition
      // Components that assemble them, the Structural Components that
      // place them, and the Layouts that name the shapes. Each owes
      // the catalogue a gallery, and the rule discovers them itself.
      const families = ['components', 'composition', 'structure', 'layout'];
      var catalogued = 0;

      for (final family in families) {
        final root = Directory('lib/foundation/design_kit/$family');
        expect(root.existsSync(), isTrue, reason: '$family must exist');
        for (final component in root.listSync().whereType<Directory>()) {
          final name = component.path
              .replaceAll(r'\', '/')
              .split('/')
              .last;
          // A component is a directory that owns its widget; the
          // shared machinery next to them owes the catalogue nothing.
          if (!File('${component.path}/mentora_$name.dart').existsSync()) {
            continue;
          }
          final galleryType =
              '${name.split('_').map((word) => '${word[0].toUpperCase()}'
                  '${word.substring(1)}').join()}Gallery';
          expect(
            gallery.contains('$family/$name/'),
            isTrue,
            reason: 'the $name component must appear in the catalogue',
          );
          expect(
            gallery.contains('class $galleryType'),
            isTrue,
            reason: 'every component owns its gallery: $galleryType',
          );
          expect(
            mounted.contains('$galleryType('),
            isTrue,
            reason: '$galleryType must be mounted in the living catalogue',
          );
          catalogued++;
        }
      }
      expect(catalogued, greaterThanOrEqualTo(families.length));
    });
  });
}
