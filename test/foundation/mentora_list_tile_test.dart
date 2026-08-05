import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:mentora/foundation/design_kit/composition/list_tile/mentora_list_tile_style.dart';
import 'package:mentora/foundation/design_kit/composition/list_tile/mentora_list_tile_theme.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/list_tile_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

void _noop() {}

MentoraListTile _entity({
  MentoraListTileDensity density = MentoraListTileDensity.standard,
  MentoraListTileChrome chrome = MentoraListTileChrome.plain,
  MentoraListTileController? controller,
  VoidCallback? onTap,
  String? semanticLabel,
  bool composed = true,
}) {
  return MentoraListTile(
    density: density,
    chrome: chrome,
    controller: controller,
    onTap: onTap,
    semanticLabel: semanticLabel,
    leading: composed
        ? MentoraAvatar(
            identity: MentoraAvatarIdentity.initials,
            name: 'Awa Mensah',
            initials: 'AM',
            size: avatarSizeOf(density),
          )
        : null,
    headline: 'Awa Mensah',
    supporting: composed ? 'Consultation de suivi' : null,
    metadata: composed ? '11:00' : null,
    badges: composed
        ? const [
            MentoraBadge(
              variant: MentoraBadgeVariant.success,
              shape: MentoraBadgeShape.compact,
              label: 'Confirmée',
            ),
          ]
        : const [],
    trailing: composed
        ? MentoraButton(
            label: 'Ouvrir',
            onPressed: _noop,
            variant: MentoraButtonVariant.text,
            size: MentoraButtonSize.small,
          )
        : null,
    footer: composed ? 'Dernier échange il y a 2 jours' : null,
  );
}

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget tile, {
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
          child: Scaffold(body: Center(child: tile)),
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
    find.byKey(const Key('list-tile-surface')),
  );
}

BoxDecoration _decorationOf(WidgetTester tester) =>
    _surfaceOf(tester).decoration! as BoxDecoration;

MentoraListTileTheme _adapter(FoundationServices services) {
  return MentoraListTileTheme(
    colors: services.get<ColorTokenEngine>(),
    spacing: services.get<SpacingTokenEngine>(),
    motion: services.get<MotionEngine>(),
    accessibility: services.get<AccessibilityEngine>(),
    appearance: const AppearanceState(),
    variant: ThemeVariantId.light,
  );
}

void main() {
  group('A tile presents an entity, never a layout', () {
    testWidgets('it composes the official components and redefines '
        'none of them', (tester) async {
      await _pump(tester, _entity());

      // Each authority is present, and each is itself.
      expect(find.byType(MentoraAvatar), findsOneWidget);
      expect(find.byType(MentoraBadge), findsOneWidget);
      expect(find.byType(MentoraButton), findsOneWidget);
      expect(find.text('Awa Mensah'), findsOneWidget);
      expect(find.text('Consultation de suivi'), findsOneWidget);
      expect(find.text('11:00'), findsOneWidget);
      expect(find.text('Dernier échange il y a 2 jours'), findsOneWidget);
    });

    testWidgets('every zone is optional: a name alone is an entity', (
      tester,
    ) async {
      await _pump(tester, _entity(composed: false));

      expect(find.text('Awa Mensah'), findsOneWidget);
      expect(find.byType(MentoraAvatar), findsNothing);
      expect(find.byType(MentoraBadge), findsNothing);
      expect(find.byType(MentoraButton), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an entity that cannot be named is refused — fail '
        'closed', (tester) async {
      await _pump(
        tester,
        const MentoraListTile(headline: ''),
      );
      expect(tester.takeException(), isStateError);
    });

    testWidgets('it announces the entity without ever silencing its '
        'parts: each authority keeps its own voice', (tester) async {
      final handle = tester.ensureSemantics();

      await _pump(tester, _entity());
      // The words the tile owns are heard as one sentence.
      final words = tester.getSemantics(find.text('Awa Mensah'));
      expect(words.label, contains('Awa Mensah'));
      expect(words.label, contains('Consultation de suivi'));
      expect(words.label, contains('11:00'));
      // The identity and the state keep theirs — a composition never
      // takes an authority away from the component that owns it.
      expect(find.bySemanticsLabel('Confirmée'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(MentoraAvatar)).label,
        'Awa Mensah',
      );

      // Given a sentence, the tile speaks that alone.
      await _pump(
        tester,
        _entity(semanticLabel: 'Consultation avec Awa Mensah, 11h, confirmée'),
      );
      expect(
        tester.getSemantics(find.byType(MentoraListTile)).label,
        'Consultation avec Awa Mensah, 11h, confirmée',
      );
      expect(find.bySemanticsLabel('Confirmée'), findsNothing);
      handle.dispose();
    });
  });

  group('Density and chrome are orthogonal', () {
    testWidgets('every density proposes its own minimum extent and its '
        'own identity size', (tester) async {
      final services = await _services();
      final adapter = _adapter(services);
      const expected = <MentoraListTileDensity, MentoraAvatarSize>{
        MentoraListTileDensity.large: MentoraAvatarSize.large,
        MentoraListTileDensity.standard: MentoraAvatarSize.medium,
        MentoraListTileDensity.compact: MentoraAvatarSize.small,
        MentoraListTileDensity.dense: MentoraAvatarSize.extraSmall,
      };
      expect(expected.length, MentoraListTileDensity.values.length);

      for (final entry in expected.entries) {
        expect(avatarSizeOf(entry.key), entry.value);
        await _pump(tester, _entity(density: entry.key, composed: false));
        expect(
          tester.getSize(find.byType(MentoraListTile)).height,
          greaterThanOrEqualTo(adapter.specOf(entry.key).minimumExtent),
        );
      }
    });

    testWidgets('every chrome delimits the entity with a role', (
      tester,
    ) async {
      final services = await _services();
      final colors = services.get<ColorTokenEngine>();

      await _pump(tester, _entity(chrome: MentoraListTileChrome.plain));
      expect(_decorationOf(tester).border, isNull);
      expect(_decorationOf(tester).color, isNull);
      expect(find.byType(Divider), findsNothing);

      await _pump(tester, _entity(chrome: MentoraListTileChrome.outlined));
      expect(
        (_decorationOf(tester).border! as Border).top.color,
        colors.colorOf(ColorRole.outline, ThemeVariantId.light),
      );

      await _pump(tester, _entity(chrome: MentoraListTileChrome.separated));
      expect(
        tester.widget<Divider>(find.byType(Divider)).color,
        colors.colorOf(ColorRole.divider, ThemeVariantId.light),
      );

      await _pump(tester, _entity(chrome: MentoraListTileChrome.highlighted));
      expect(_decorationOf(tester).color, isNotNull);
    });

    testWidgets('an act is what makes a tile interactive — and any '
        'chrome may invite one', (tester) async {
      var opened = 0;
      await _pump(
        tester,
        _entity(
          chrome: MentoraListTileChrome.outlined,
          onTap: () => opened++,
        ),
      );

      await tester.tap(find.text('Awa Mensah'));
      await tester.pump();
      expect(opened, 1);
      // The chrome is untouched by the act.
      expect(_decorationOf(tester).border, isNotNull);
    });

    testWidgets('an entity that invites an act is a target; one that '
        'does not is never forced to be', (tester) async {
      await _pump(
        tester,
        _entity(density: MentoraListTileDensity.dense, composed: false),
      );
      expect(
        tester.getSize(find.byType(MentoraListTile)).height,
        denseListTileSpec.minimumExtent,
      );

      await _pump(
        tester,
        _entity(
          density: MentoraListTileDensity.dense,
          composed: false,
          onTap: _noop,
        ),
      );
      expect(
        tester.getSize(find.byType(MentoraListTile)).height,
        greaterThanOrEqualTo(48),
      );
    });
  });

  group('The state of an entity is announced from outside', () {
    testWidgets('selected is brought forward, disabled is veiled, '
        'archived stays readable', (tester) async {
      final services = await _services();
      final colors = services.get<ColorTokenEngine>();

      await _pump(
        tester,
        _entity(
          controller: MentoraListTileController(
            MentoraListTileStatus.selected,
          ),
          chrome: MentoraListTileChrome.outlined,
        ),
      );
      expect(
        _decorationOf(tester).color,
        colors.colorOf(ColorRole.highlight, ThemeVariantId.light),
      );
      expect(
        (_decorationOf(tester).border! as Border).top.color,
        colors.colorOf(ColorRole.selection, ThemeVariantId.light),
      );

      const veiled = <MentoraListTileStatus, double>{
        MentoraListTileStatus.disabled: listTileDisabledVeilOpacity,
        MentoraListTileStatus.archived: listTileArchivedOpacity,
        MentoraListTileStatus.idle: listTileFullOpacity,
      };
      for (final entry in veiled.entries) {
        await _pump(
          tester,
          _entity(controller: MentoraListTileController(entry.key)),
        );
        expect(
          tester
              .widget<Opacity>(find.byKey(const Key('list-tile-presence')))
              .opacity,
          entry.value,
        );
        // An entity is never removed: it stays on screen.
        expect(find.text('Awa Mensah'), findsOneWidget);
      }
    });

    testWidgets('while an entity is loading, no act is offered twice', (
      tester,
    ) async {
      var opened = 0;
      final controller = MentoraListTileController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        _entity(controller: controller, onTap: () => opened++),
      );

      controller.announce(MentoraListTileStatus.loading);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(MentoraButton), findsNothing);
      expect(find.byType(MentoraBadge), findsNothing);

      await tester.tap(find.text('Awa Mensah'));
      await tester.pump();
      expect(opened, 0);
    });

    testWidgets('a disabled entity refuses the act it used to invite', (
      tester,
    ) async {
      var opened = 0;
      await _pump(
        tester,
        _entity(
          controller: MentoraListTileController(
            MentoraListTileStatus.disabled,
          ),
          onTap: () => opened++,
        ),
      );

      await tester.tap(find.text('Awa Mensah'), warnIfMissed: false);
      await tester.pump();
      expect(opened, 0);
    });

    testWidgets('the focus delimits with the focus role, and the '
        'keyboard reaches the entity', (tester) async {
      final services = await _pump(tester, _entity(onTap: _noop));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(
        (_decorationOf(tester).border! as Border).top.color,
        services
            .get<ColorTokenEngine>()
            .colorOf(ColorRole.focus, ThemeVariantId.light),
      );
    });
  });

  group('It travels, and it never restyles a child', () {
    testWidgets('the four theme variants each serve their own Tokens', (
      tester,
    ) async {
      for (final variant in ThemeVariantId.values) {
        final services = await _pump(
          tester,
          _entity(
            controller: MentoraListTileController(
              MentoraListTileStatus.selected,
            ),
          ),
          variant: variant,
        );
        expect(
          _decorationOf(tester).color,
          services.get<ColorTokenEngine>().colorOf(
            ColorRole.highlight,
            variant,
          ),
        );
      }
    });

    testWidgets('both directions and every reading comfort are served '
        'without any special handling', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _entity(), direction: direction);
        expect(tester.takeException(), isNull);
        expect(find.text('Awa Mensah'), findsOneWidget);
      }

      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          _entity(),
          appearance: AppearanceState(readingComfort: comfort),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('every transition comes from the Motion Engine: None '
        'silences it', (tester) async {
      const appearance = AppearanceState();
      final services = await _pump(tester, _entity());
      expect(
        _surfaceOf(tester).duration,
        services
            .get<MotionEngine>()
            .durationFor(MotionIntention.accompagner, appearance),
      );

      await _pump(
        tester,
        _entity(),
        appearance: const AppearanceState(motion: MotionPreference.none),
      );
      expect(_surfaceOf(tester).duration, Duration.zero);
    });

    testWidgets('outside the Design Kit the tile refuses to build — '
        'fail closed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MentoraListTile(headline: 'Awa Mensah')),
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

    test('no framework list tile of any kind survives in the '
        'foundation', () {
      final forbidden = <String, RegExp>{
        'ListTile': RegExp(r'(?<![A-Za-z])ListTile\('),
        'CheckboxListTile': RegExp(r'(?<![A-Za-z])CheckboxListTile\('),
        'RadioListTile': RegExp(r'(?<![A-Za-z])RadioListTile\('),
        'SwitchListTile': RegExp(r'(?<![A-Za-z])SwitchListTile\('),
        'ExpansionTile': RegExp(r'(?<![A-Za-z])ExpansionTile\('),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: an entity is a MentoraListTile — never a '
                '${entry.key}',
          );
        }
      }
    });

    test('a Composition Component composes official components, and '
        'builds none of what they own', () {
      // Structural, never lexical: what is forbidden is re-creating in
      // code what a Core Component owns, and importing anything that
      // is not an official component or the Kit itself.
      final rebuilds = <String, RegExp>{
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
        'its own pictogram': RegExp(r'(?<![A-Za-z])Icon\('),
        'a coded size': RegExp(r'fontSize:'),
        'a coded weight': RegExp(r'FontWeight\.'),
      };
      final import = RegExp(r"import '[.][.]/[.][.]/([a-z_]+)/");
      const admitted = {
        'components',
        'tokens',
        'registry',
        'theme',
        'motion',
        'appearance',
        'accessibility',
      };

      final files = dartFilesOf('lib/foundation/design_kit/composition');
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in rebuilds.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a composition never rebuilds '
                '${entry.key} — the component that owns it does',
          );
        }
        for (final match in import.allMatches(source)) {
          expect(
            admitted,
            contains(match.group(1)),
            reason:
                '${file.path}: a composition assembles official '
                'components and consumes the Kit — nothing else',
          );
        }
      }
    });

    test('no Core Component reads the ambient theme, and no colour, '
        'padding or radius is ever coded outside the Tokens', () {
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
