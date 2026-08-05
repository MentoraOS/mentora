import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/avatar/mentora_avatar.dart';
import 'package:mentora/foundation/design_kit/components/avatar/mentora_avatar_style.dart';
import 'package:mentora/foundation/design_kit/components/avatar/mentora_avatar_theme.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/avatar_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

/// A portrait that will never decode: the identity must survive it.
final MemoryImage _brokenPortrait = MemoryImage(
  Uint8List.fromList(const [0, 1, 2, 3]),
);

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget avatar, {
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
  TextDirection direction = TextDirection.ltr,
  double? textScale,
  bool settle = true,
}) async {
  final services = await _services();
  await tester.pumpWidget(
    MaterialApp(
      theme: services.get<ThemeEngine>().themeForVariant(variant),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: textScale == null
              ? media
              : media.copyWith(textScaler: TextScaler.linear(textScale)),
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
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      home: Scaffold(body: Center(child: avatar)),
    ),
  );
  // An identity that is still arriving shows a signal that never
  // comes to rest: those pumps are counted, never settled.
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return services;
}

BoxDecoration _decorationOf(WidgetTester tester) {
  return tester
          .widget<AnimatedContainer>(
            find.descendant(
              of: find.byType(MentoraAvatar),
              matching: find.byType(AnimatedContainer),
            ),
          )
          .decoration
      as BoxDecoration;
}

MentoraAvatarTheme _adapter(FoundationServices services) {
  return MentoraAvatarTheme(
    colors: services.get<ColorTokenEngine>(),
    surfaces: services.get<SurfaceTokenEngine>(),
    motion: services.get<MotionEngine>(),
    appearance: const AppearanceState(),
    variant: ThemeVariantId.light,
  );
}

void main() {
  group('An identity survives the absence of an image', () {
    testWidgets('with no portrait, the initials speak', (tester) async {
      await _pump(
        tester,
        const MentoraAvatar(
          identity: MentoraAvatarIdentity.initials,
          name: 'Awa Mensah',
          initials: 'AM',
        ),
      );

      expect(find.text('AM'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('with no portrait and no initials, the identity mark '
        'stands for it', (tester) async {
      final services = await _pump(
        tester,
        const MentoraAvatar(
          identity: MentoraAvatarIdentity.organisation,
          name: 'Ordre des experts',
        ),
      );

      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(MentoraAvatar),
          matching: find.byType(Icon),
        ),
      );
      expect(icon.icon, _adapter(services).markOf(
        MentoraAvatarIdentity.organisation,
      ));
    });

    testWidgets('a portrait that cannot be shown hands over — never an '
        'error, never an empty circle', (tester) async {
      await _pump(
        tester,
        MentoraAvatar(
          identity: MentoraAvatarIdentity.photo,
          name: 'Awa Mensah',
          initials: 'AM',
          portrait: _brokenPortrait,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AM'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a collective or system identity always speaks through '
        'its own mark, never through a portrait', (tester) async {
      for (final identity in const [
        MentoraAvatarIdentity.ai,
        MentoraAvatarIdentity.system,
        MentoraAvatarIdentity.unknown,
        MentoraAvatarIdentity.loading,
      ]) {
        expect(acceptsPortrait(identity), isFalse);
        expect(acceptsInitials(identity), isFalse);
        await _pump(
          tester,
          MentoraAvatar(
            identity: identity,
            name: identity.name,
            initials: 'AM',
            portrait: _brokenPortrait,
          ),
        );
        expect(find.byType(Image), findsNothing);
        expect(find.text('AM'), findsNothing);
        expect(
          find.descendant(
            of: find.byType(MentoraAvatar),
            matching: find.byType(Icon),
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('an unresolved identity is not a portrait still '
        'arriving: both exist, and they differ', (tester) async {
      await _pump(
        tester,
        const MentoraAvatar(
          identity: MentoraAvatarIdentity.loading,
          name: 'Identité en cours',
        ),
      );
      // The identity itself is unknown yet: its mark stands for it.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        find.descendant(
          of: find.byType(MentoraAvatar),
          matching: find.byType(Icon),
        ),
        findsOneWidget,
      );

      await _pump(
        tester,
        const MentoraAvatar(
          identity: MentoraAvatarIdentity.photo,
          name: 'Awa Mensah',
          initials: 'AM',
          state: MentoraAvatarState.loading,
        ),
        settle: false,
      );
      // The identity is known; its portrait is still arriving.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('AM'), findsNothing);
    });
  });

  group('An identity is announced, never described as an image', () {
    testWidgets('the name is what the screen reader hears — announced '
        'exactly once', (tester) async {
      final handle = tester.ensureSemantics();

      await _pump(
        tester,
        const MentoraAvatar(
          identity: MentoraAvatarIdentity.initials,
          name: 'Awa Mensah',
          initials: 'AM',
        ),
      );
      expect(
        tester.getSemantics(find.byType(MentoraAvatar)).label,
        'Awa Mensah',
      );
      // What it paints never speaks a second time.
      expect(
        find.descendant(
          of: find.byType(MentoraAvatar),
          matching: find.bySemanticsLabel('AM'),
        ),
        findsNothing,
      );

      await _pump(
        tester,
        const MentoraAvatar(
          identity: MentoraAvatarIdentity.ai,
          name: 'Copilote',
          semanticLabel: 'Copilote Mentora — intelligence artificielle',
        ),
      );
      expect(
        tester.getSemantics(find.byType(MentoraAvatar)).label,
        'Copilote Mentora — intelligence artificielle',
      );
      handle.dispose();
    });

    testWidgets('an identity that cannot be named is refused — fail '
        'closed', (tester) async {
      await _pump(
        tester,
        const MentoraAvatar(
          identity: MentoraAvatarIdentity.user,
          name: '',
        ),
      );
      expect(tester.takeException(), isStateError);
    });
  });

  group('The identity language speaks in roles', () {
    testWidgets('every identity kind names itself with a role — never a '
        'decoration', (tester) async {
      final services = await _services();
      final adapter = _adapter(services);
      const expected = <MentoraAvatarIdentity, ColorRole>{
        MentoraAvatarIdentity.photo: ColorRole.primary,
        MentoraAvatarIdentity.initials: ColorRole.primary,
        MentoraAvatarIdentity.user: ColorRole.primary,
        MentoraAvatarIdentity.organisation: ColorRole.secondary,
        MentoraAvatarIdentity.company: ColorRole.secondary,
        MentoraAvatarIdentity.ai: ColorRole.aiSuggestion,
        MentoraAvatarIdentity.system: ColorRole.information,
        MentoraAvatarIdentity.guest: ColorRole.supporting,
        MentoraAvatarIdentity.unknown: ColorRole.neutral,
        MentoraAvatarIdentity.loading: ColorRole.neutral,
      };

      expect(expected.length, MentoraAvatarIdentity.values.length);
      for (final entry in expected.entries) {
        expect(adapter.accentRoleOf(entry.key), entry.value);
      }
    });

    testWidgets('the initials wear the accent of their identity, '
        'resolved from a role', (tester) async {
      final services = await _pump(
        tester,
        const MentoraAvatar(
          identity: MentoraAvatarIdentity.company,
          name: 'Mentora SA',
          initials: 'MS',
        ),
      );

      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: find.byType(MentoraAvatar),
                matching: find.byType(Text),
              ),
            )
            .style
            ?.color,
        services
            .get<ColorTokenEngine>()
            .colorOf(ColorRole.secondary, ThemeVariantId.light),
      );
    });

    testWidgets('a circle is half of itself, a rounded identity keeps '
        'its softness, a square is squared', (tester) async {
      final services = await _services();
      final adapter = _adapter(services);
      for (final size in MentoraAvatarSize.values) {
        final extent = adapter.specOf(size).extent;
        expect(
          adapter.radiusOf(MentoraAvatarShape.circle, size).topLeft.x,
          extent / 2,
        );
        expect(
          adapter.radiusOf(MentoraAvatarShape.rounded, size).topLeft.x,
          extent * avatarRoundedRadiusFactor,
        );
        expect(
          adapter.radiusOf(MentoraAvatarShape.square, size).topLeft.x,
          avatarSquareRadius,
        );
      }
    });

    testWidgets('every extent is served by its Token', (tester) async {
      final services = await _services();
      final adapter = _adapter(services);
      for (final size in MentoraAvatarSize.values) {
        await _pump(
          tester,
          MentoraAvatar(
            identity: MentoraAvatarIdentity.user,
            name: size.name,
            size: size,
          ),
        );
        expect(
          tester.getSize(find.byType(MentoraAvatar)).height,
          adapter.specOf(size).extent,
        );
      }
    });

    testWidgets('every state is expressed: unavailable is dimmed never '
        'removed, disabled is veiled, archived stays readable', (
      tester,
    ) async {
      const expected = <MentoraAvatarState, double>{
        MentoraAvatarState.idle: avatarFullOpacity,
        MentoraAvatarState.unavailable: avatarUnavailableOpacity,
        MentoraAvatarState.disabled: avatarDisabledVeilOpacity,
        MentoraAvatarState.archived: avatarArchivedOpacity,
      };
      for (final entry in expected.entries) {
        await _pump(
          tester,
          MentoraAvatar(
            identity: MentoraAvatarIdentity.user,
            name: 'Awa Mensah',
            initials: 'AM',
            state: entry.key,
          ),
        );
        expect(
          tester
              .widget<Opacity>(
                find.descendant(
                  of: find.byType(MentoraAvatar),
                  matching: find.byType(Opacity),
                ),
              )
              .opacity,
          entry.value,
          reason: '${entry.key.name} must be expressed by its Token',
        );
        // An identity is never removed: it stays on screen.
        expect(find.text('AM'), findsOneWidget);
      }
    });

    testWidgets('the state comes from outside: the controller prevails '
        'over the resting value', (tester) async {
      final controller = MentoraAvatarController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        MentoraAvatar(
          identity: MentoraAvatarIdentity.user,
          name: 'Awa Mensah',
          initials: 'AM',
          controller: controller,
        ),
      );
      expect(find.text('AM'), findsOneWidget);

      controller.announce(MentoraAvatarState.loading);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('AM'), findsNothing);
    });
  });

  group('It stays pure, and it travels', () {
    testWidgets('it offers no act: no gesture, no ink, no focus', (
      tester,
    ) async {
      await _pump(
        tester,
        const MentoraAvatar(
          identity: MentoraAvatarIdentity.user,
          name: 'Awa Mensah',
        ),
      );

      for (final forbidden in [
        find.byType(GestureDetector),
        find.byType(InkWell),
        find.byType(Focus),
      ]) {
        expect(
          find.descendant(of: find.byType(MentoraAvatar), matching: forbidden),
          findsNothing,
        );
      }
    });

    testWidgets('the four theme variants each serve their own Tokens', (
      tester,
    ) async {
      for (final variant in ThemeVariantId.values) {
        final services = await _pump(
          tester,
          const MentoraAvatar(
            identity: MentoraAvatarIdentity.system,
            name: 'Mentora',
            state: MentoraAvatarState.archived,
          ),
          variant: variant,
        );
        expect(
          _decorationOf(tester).color,
          services.get<SurfaceTokenEngine>().surfaceOf(
            SurfaceRole.secondarySurface,
            variant,
          ),
        );
      }
    });

    testWidgets('the font scale grows the initials — applied once, by '
        'the application', (tester) async {
      await _pump(
        tester,
        const MentoraAvatar(
          identity: MentoraAvatarIdentity.initials,
          name: 'Awa Mensah',
          initials: 'AM',
          size: MentoraAvatarSize.doubleExtraLarge,
        ),
      );
      final standard = tester.getSize(find.text('AM')).height;

      await _pump(
        tester,
        const MentoraAvatar(
          identity: MentoraAvatarIdentity.initials,
          name: 'Awa Mensah',
          initials: 'AM',
          size: MentoraAvatarSize.doubleExtraLarge,
        ),
        appearance: const AppearanceState(
          fontScale: FontScalePreference.extraLarge,
        ),
        textScale: const AccessibilityEngine().textScaleFor(
          const AppearanceState(fontScale: FontScalePreference.extraLarge),
        ),
      );
      expect(tester.getSize(find.text('AM')).height, greaterThan(standard));
      expect(tester.takeException(), isNull);
    });

    testWidgets('both directions and every reading comfort are served '
        'without any special handling', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(
          tester,
          const MentoraAvatar(
            identity: MentoraAvatarIdentity.company,
            name: 'شركة منتورا',
            initials: 'شم',
          ),
          direction: direction,
        );
        expect(tester.takeException(), isNull);
        expect(find.text('شم'), findsOneWidget);
      }

      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          MentoraAvatar(
            identity: MentoraAvatarIdentity.guest,
            name: comfort.name,
          ),
          appearance: AppearanceState(readingComfort: comfort),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('every transition comes from the Motion Engine: None '
        'silences it', (tester) async {
      const appearance = AppearanceState();
      final services = await _pump(
        tester,
        const MentoraAvatar(
          identity: MentoraAvatarIdentity.user,
          name: 'Awa Mensah',
        ),
      );
      AnimatedContainer container() => tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(MentoraAvatar),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(
        container().duration,
        services
            .get<MotionEngine>()
            .durationFor(MotionIntention.accompagner, appearance),
      );

      await _pump(
        tester,
        const MentoraAvatar(
          identity: MentoraAvatarIdentity.user,
          name: 'Awa Mensah',
        ),
        appearance: const AppearanceState(motion: MotionPreference.none),
      );
      expect(container().duration, Duration.zero);
    });

    testWidgets('outside the Design Kit the avatar refuses to build — '
        'fail closed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MentoraAvatar(
              identity: MentoraAvatarIdentity.user,
              name: 'Awa Mensah',
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

    test('no framework avatar or account header survives in the '
        'foundation', () {
      final forbidden = <String, RegExp>{
        'CircleAvatar': RegExp(r'(?<![A-Za-z])CircleAvatar\b'),
        'UserAccountsDrawerHeader': RegExp(
          r'(?<![A-Za-z])UserAccountsDrawerHeader\b',
        ),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: an identity is a MentoraAvatar — never a '
                '${entry.key}',
          );
        }
      }
    });

    test('an avatar carries no act, and composes no component other '
        'than its words: it stays deliberately pure', () {
      // The rule is structural, never lexical: what is forbidden is an
      // act in the code and an import of another component — the prose
      // of the documentation stays free to name what it refuses.
      final act = RegExp(
        r'(?<![A-Za-z])(VoidCallback|GestureDetector|InkWell|'
        r'GestureRecognizer|onTap|onPressed)(?![A-Za-z])',
      );
      final componentImport = RegExp(r"import '[.][.]/([a-z_]+)/");
      for (final file in dartFilesOf(
        'lib/foundation/design_kit/components/avatar',
      )) {
        final source = file.readAsStringSync();
        expect(
          act.hasMatch(source),
          isFalse,
          reason: '${file.path}: an avatar one can act on is not an avatar',
        );
        for (final match in componentImport.allMatches(source)) {
          expect(
            match.group(1),
            'text',
            reason:
                '${file.path}: decorators are composed AROUND an avatar, '
                'never inside it — only its words are composed',
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
        final normalized = file.path.replaceAll('\\', '/');
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
