import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/badge/mentora_badge.dart';
import 'package:mentora/foundation/design_kit/components/badge/mentora_badge_style.dart';
import 'package:mentora/foundation/design_kit/components/badge/mentora_badge_theme.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/badge_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget badge, {
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
      home: Scaffold(body: Center(child: badge)),
    ),
  );
  // A badge that reports a settling state shows a signal that never
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
              of: find.byType(MentoraBadge),
              matching: find.byType(AnimatedContainer),
            ),
          )
          .decoration
      as BoxDecoration;
}

MentoraBadgeTheme _adapter(FoundationServices services) {
  return MentoraBadgeTheme(
    colors: services.get<ColorTokenEngine>(),
    spacing: services.get<SpacingTokenEngine>(),
    motion: services.get<MotionEngine>(),
    appearance: const AppearanceState(),
    variant: ThemeVariantId.light,
  );
}

void main() {
  group('A badge affirms a state', () {
    testWidgets('every variant names its state with a role — never a '
        'decoration', (tester) async {
      final services = await _services();
      final adapter = _adapter(services);
      const expected = <MentoraBadgeVariant, ColorRole>{
        MentoraBadgeVariant.neutral: ColorRole.neutral,
        MentoraBadgeVariant.information: ColorRole.information,
        MentoraBadgeVariant.success: ColorRole.success,
        MentoraBadgeVariant.warning: ColorRole.warning,
        MentoraBadgeVariant.critical: ColorRole.critical,
        MentoraBadgeVariant.verified: ColorRole.verified,
        MentoraBadgeVariant.premium: ColorRole.secondary,
        MentoraBadgeVariant.ai: ColorRole.aiSuggestion,
        MentoraBadgeVariant.offline: ColorRole.unavailable,
        MentoraBadgeVariant.sync: ColorRole.information,
        MentoraBadgeVariant.custom: ColorRole.neutral,
      };

      expect(expected.length, MentoraBadgeVariant.values.length);
      for (final entry in expected.entries) {
        expect(adapter.accentRoleOf(entry.key), entry.value);
      }
    });

    testWidgets('the words wear the accent of the state, resolved from '
        'a role', (tester) async {
      final services = await _pump(
        tester,
        const MentoraBadge(
          variant: MentoraBadgeVariant.verified,
          label: 'Vérifié',
        ),
      );

      final text = tester.widget<Text>(
        find.descendant(
          of: find.byType(MentoraBadge),
          matching: find.byType(Text),
        ),
      );
      expect(
        text.style?.color,
        services
            .get<ColorTokenEngine>()
            .colorOf(ColorRole.verified, ThemeVariantId.light),
      );
    });

    testWidgets('it never competes with a title: only non-structural '
        'roles are ever served', (tester) async {
      final services = await _services();
      final adapter = _adapter(services);
      const structural = [
        MentoraTextRole.headline,
        MentoraTextRole.title,
        MentoraTextRole.subtitle,
      ];
      for (final size in MentoraBadgeSize.values) {
        expect(structural, isNot(contains(adapter.textRoleOf(size))));
      }
    });

    testWidgets('a form is a decision about room, never about '
        'decoration: only the label form is squared', (tester) async {
      final services = await _services();
      final adapter = _adapter(services);
      expect(adapter.radiusOf(MentoraBadgeShape.label), badgeCornerRadius);
      for (final shape in MentoraBadgeShape.values) {
        if (shape == MentoraBadgeShape.label) continue;
        expect(adapter.radiusOf(shape), badgeFullRadius);
      }
      expect(showsWords(MentoraBadgeShape.dot), isFalse);
      expect(showsWords(MentoraBadgeShape.icon), isFalse);
      expect(showsIcon(MentoraBadgeShape.pill), isFalse);
      expect(showsIcon(MentoraBadgeShape.extended), isTrue);
    });

    testWidgets('the dot is a mark alone — no ground, no border, no '
        'words', (tester) async {
      await _pump(
        tester,
        const MentoraBadge(
          variant: MentoraBadgeVariant.critical,
          shape: MentoraBadgeShape.dot,
          semanticLabel: 'Action requise',
        ),
      );

      final decoration = _decorationOf(tester);
      expect(decoration.color, isNull);
      expect(decoration.border, isNull);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('every state is expressed: disabled is veiled, '
        'archived is a memory, processing shows one sober signal', (
      tester,
    ) async {
      await _pump(
        tester,
        const MentoraBadge(
          variant: MentoraBadgeVariant.success,
          label: 'Confirmé',
          state: MentoraBadgeState.disabled,
        ),
      );
      expect(
        tester
            .widget<Opacity>(
              find.descendant(
                of: find.byType(MentoraBadge),
                matching: find.byType(Opacity),
              ),
            )
            .opacity,
        badgeDisabledVeilOpacity,
      );

      await _pump(
        tester,
        const MentoraBadge(
          variant: MentoraBadgeVariant.success,
          label: 'Archivé',
          state: MentoraBadgeState.archived,
        ),
      );
      expect(
        tester
            .widget<Opacity>(
              find.descendant(
                of: find.byType(MentoraBadge),
                matching: find.byType(Opacity),
              ),
            )
            .opacity,
        badgeArchivedOpacity,
      );

      await _pump(
        tester,
        const MentoraBadge(
          variant: MentoraBadgeVariant.sync,
          shape: MentoraBadgeShape.compact,
          label: 'Synchronisation',
          state: MentoraBadgeState.processing,
        ),
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('what is brought forward is filled by its own accent', (
      tester,
    ) async {
      final services = await _pump(
        tester,
        const MentoraBadge(
          variant: MentoraBadgeVariant.premium,
          label: 'Premium',
          state: MentoraBadgeState.selected,
        ),
      );

      expect(
        (_decorationOf(tester).border! as Border).top.color,
        services
            .get<ColorTokenEngine>()
            .colorOf(ColorRole.secondary, ThemeVariantId.light),
      );
    });

    testWidgets('the state comes from outside: the controller prevails '
        'over the resting value', (tester) async {
      final controller = MentoraBadgeController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        MentoraBadge(
          variant: MentoraBadgeVariant.information,
          label: 'État',
          controller: controller,
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);

      controller.announce(MentoraBadgeState.processing);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('A badge is never interactive', () {
    testWidgets('it offers no act: no gesture, no ink, no focus', (
      tester,
    ) async {
      await _pump(
        tester,
        const MentoraBadge(
          variant: MentoraBadgeVariant.verified,
          label: 'Vérifié',
        ),
      );

      expect(
        find.descendant(
          of: find.byType(MentoraBadge),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(MentoraBadge),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(MentoraBadge),
          matching: find.byType(Focus),
        ),
        findsNothing,
      );
    });

    testWidgets('it is not a target: it never claims the reachable '
        'minimum it does not need', (tester) async {
      await _pump(
        tester,
        const MentoraBadge(
          variant: MentoraBadgeVariant.information,
          size: MentoraBadgeSize.small,
          label: 'Nouveau',
        ),
      );

      // The opposable floor protects targets; a badge carries no act,
      // so what stays opposable for it is legibility, not reach.
      expect(
        tester.getSize(find.byType(MentoraBadge)).height,
        lessThan(48),
      );
      expect(
        tester.getSize(find.byType(MentoraBadge)).height,
        greaterThanOrEqualTo(smallBadgeSpec.height),
      );
    });
  });

  group('A state is never carried by colour alone', () {
    testWidgets('a form without words requires its meaning — fail '
        'closed', (tester) async {
      await _pump(
        tester,
        const MentoraBadge(
          variant: MentoraBadgeVariant.critical,
          shape: MentoraBadgeShape.dot,
        ),
      );
      expect(tester.takeException(), isStateError);

      await _pump(
        tester,
        const MentoraBadge(
          variant: MentoraBadgeVariant.critical,
          shape: MentoraBadgeShape.icon,
        ),
      );
      expect(tester.takeException(), isStateError);
    });

    testWidgets('the screen reader hears the value, the status and the '
        'context — announced exactly once', (tester) async {
      final handle = tester.ensureSemantics();

      await _pump(
        tester,
        const MentoraBadge(
          variant: MentoraBadgeVariant.verified,
          shape: MentoraBadgeShape.compact,
          label: 'Vérifié',
          semanticLabel: 'Profil vérifié — vérification terminée',
        ),
      );

      final node = tester.getSemantics(find.byType(MentoraBadge));
      expect(node.label, 'Profil vérifié — vérification terminée');
      // What it paints never speaks a second time.
      expect(
        find.descendant(
          of: find.byType(MentoraBadge),
          matching: find.bySemanticsLabel('Vérifié'),
        ),
        findsNothing,
      );
      handle.dispose();
    });

    testWidgets('a form with words speaks them when nothing else is '
        'given', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const MentoraBadge(
          variant: MentoraBadgeVariant.success,
          label: 'Confirmé',
        ),
      );
      expect(
        tester.getSemantics(find.byType(MentoraBadge)).label,
        'Confirmé',
      );
      handle.dispose();
    });
  });

  group('It travels: themes, scales, comfort and directions', () {
    testWidgets('the four theme variants each serve their own Tokens', (
      tester,
    ) async {
      for (final variant in ThemeVariantId.values) {
        final services = await _pump(
          tester,
          const MentoraBadge(
            variant: MentoraBadgeVariant.information,
            shape: MentoraBadgeShape.dot,
            semanticLabel: 'Information',
          ),
          variant: variant,
        );
        expect(
          _decorationOf(tester).color,
          isNull,
          reason: 'the dot paints its mark, not a ground',
        );
        expect(
          tester
              .widget<DecoratedBox>(find.byKey(const Key('badge-mark')))
              .decoration,
          isA<BoxDecoration>().having(
            (d) => d.color,
            'mark',
            services.get<ColorTokenEngine>().colorOf(
              ColorRole.information,
              variant,
            ),
          ),
        );
      }
    });

    testWidgets('the font scale grows the badge with its words — '
        'applied once, by the application', (tester) async {
      await _pump(
        tester,
        const MentoraBadge(
          variant: MentoraBadgeVariant.information,
          label: 'Nouveau',
        ),
      );
      final standardWords = tester.getSize(find.text('Nouveau')).height;
      final standardBadge = tester.getSize(find.byType(MentoraBadge)).height;

      await _pump(
        tester,
        const MentoraBadge(
          variant: MentoraBadgeVariant.information,
          label: 'Nouveau',
        ),
        appearance: const AppearanceState(
          fontScale: FontScalePreference.extraLarge,
        ),
        textScale: const AccessibilityEngine().textScaleFor(
          const AppearanceState(fontScale: FontScalePreference.extraLarge),
        ),
      );
      // The words grow — and the badge follows them, never clipping,
      // while never shrinking below its own minimum.
      expect(
        tester.getSize(find.text('Nouveau')).height,
        greaterThan(standardWords),
      );
      expect(
        tester.getSize(find.byType(MentoraBadge)).height,
        greaterThanOrEqualTo(standardBadge),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('both directions and every reading comfort are served '
        'without any special handling', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(
          tester,
          const MentoraBadge(
            variant: MentoraBadgeVariant.offline,
            shape: MentoraBadgeShape.extended,
            label: 'غير متصل',
          ),
          direction: direction,
        );
        expect(tester.takeException(), isNull);
        expect(find.text('غير متصل'), findsOneWidget);
      }

      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          const MentoraBadge(
            variant: MentoraBadgeVariant.neutral,
            label: 'Standard',
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
        const MentoraBadge(
          variant: MentoraBadgeVariant.success,
          label: 'Confirmé',
        ),
      );
      AnimatedContainer container() => tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(MentoraBadge),
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
        const MentoraBadge(
          variant: MentoraBadgeVariant.success,
          label: 'Confirmé',
        ),
        appearance: const AppearanceState(motion: MotionPreference.none),
      );
      expect(container().duration, Duration.zero);
    });

    testWidgets('outside the Design Kit the badge refuses to build — '
        'fail closed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MentoraBadge(
              variant: MentoraBadgeVariant.neutral,
              label: 'x',
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

    test('no Material chip of any kind survives in the foundation', () {
      final forbidden = <String, RegExp>{
        'Chip': RegExp(r'(?<![A-Za-z])Chip\('),
        'InputChip': RegExp(r'(?<![A-Za-z])InputChip\('),
        'ChoiceChip': RegExp(r'(?<![A-Za-z])ChoiceChip\('),
        'FilterChip': RegExp(r'(?<![A-Za-z])FilterChip\('),
        'ActionChip': RegExp(r'(?<![A-Za-z])ActionChip\('),
        'RawChip': RegExp(r'(?<![A-Za-z])RawChip\('),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a state is a badge — never a ${entry.key}',
          );
        }
      }
    });

    test('a badge carries no act: no callback, no gesture, no '
        'destination', () {
      for (final file in dartFilesOf(
        'lib/foundation/design_kit/components/badge',
      )) {
        final source = file.readAsStringSync();
        for (final forbidden in const [
          'VoidCallback',
          'onTap',
          'onPressed',
          'GestureDetector',
          'InkWell',
          'GestureRecognizer',
        ]) {
          expect(
            source.contains(forbidden),
            isFalse,
            reason:
                '${file.path}: a badge one can act on is no longer a '
                'badge ($forbidden)',
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
