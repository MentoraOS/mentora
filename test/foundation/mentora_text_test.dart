import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_theme.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/localization/localization_engine.dart';

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget text, {
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
  TextDirection direction = TextDirection.ltr,
  double? textScale,
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
      home: Scaffold(body: Center(child: text)),
    ),
  );
  await tester.pumpAndSettle();
  return services;
}

Text _rendered(WidgetTester tester) {
  return tester.widget<Text>(
    find.descendant(
      of: find.byType(MentoraText),
      matching: find.byType(Text),
    ),
  );
}

void main() {
  testWidgets('a behavior becomes exactly its admitted role Token — no '
      'style is ever invented', (tester) async {
    final services = await _pump(
      tester,
      const MentoraText('Consultation', role: MentoraTextRole.title),
    );

    final expected = services
        .get<TypographyTokenEngine>()
        .styleOf(TypographyRole.pageTitle, ThemeVariantId.light);
    final style = _rendered(tester).style!;
    expect(style.fontSize, expected.fontSize);
    expect(style.fontWeight, expected.fontWeight);
    expect(style.color, expected.color);
  });

  test('the ten official behaviors designate admitted roles — none is '
      'created', () {
    expect(MentoraTextRole.officialBehaviors.length, 10);
    for (final behavior in MentoraTextRole.officialBehaviors.values) {
      expect(TypographyRole.values, contains(behavior.role));
    }
    // Each behavior designates a distinct role: never two doors onto
    // the same word (CFU-02 applied).
    final designated = MentoraTextRole.officialBehaviors.values
        .map((behavior) => behavior.role)
        .toSet();
    expect(designated.length, 10);
  });

  testWidgets('every one of the 27 admitted roles is reachable and '
      'resolves', (tester) async {
    final services = await _services();
    final engine = services.get<TypographyTokenEngine>();
    for (final role in TypographyRole.values) {
      final adapter = MentoraTextTheme(
        typography: engine,
        colors: services.get<ColorTokenEngine>(),
        appearance: const AppearanceState(),
        variant: ThemeVariantId.light,
      );
      expect(
        adapter.styleOf(MentoraTextRole.of(role)).fontSize,
        engine.styleOf(role, ThemeVariantId.light).fontSize,
      );
    }
  });

  testWidgets('a color override is a ROLE — never a coded color', (
    tester,
  ) async {
    final services = await _pump(
      tester,
      const MentoraText(
        'Indisponible',
        role: MentoraTextRole.status,
        color: ColorRole.critical,
      ),
    );

    expect(
      _rendered(tester).style?.color,
      services
          .get<ColorTokenEngine>()
          .colorOf(ColorRole.critical, ThemeVariantId.light),
    );
  });

  testWidgets('the four theme variants each serve their own Tokens — '
      'high contrast included', (tester) async {
    for (final variant in ThemeVariantId.values) {
      final services = await _pump(
        tester,
        const MentoraText('Consultation', role: MentoraTextRole.body),
        variant: variant,
      );
      expect(
        _rendered(tester).style?.color,
        services
            .get<TypographyTokenEngine>()
            .styleOf(TypographyRole.body, variant)
            .color,
      );
    }
  });

  testWidgets('the font scale is applied once, by the application: the '
      'component never scales a second time', (tester) async {
    final services = await _services();
    final expected = services
        .get<TypographyTokenEngine>()
        .styleOf(TypographyRole.body, ThemeVariantId.light)
        .fontSize;

    await _pump(
      tester,
      const MentoraText('Consultation', role: MentoraTextRole.body),
    );
    final standardHeight = tester.getSize(find.byType(MentoraText)).height;
    expect(_rendered(tester).style?.fontSize, expected);

    await _pump(
      tester,
      const MentoraText('Consultation', role: MentoraTextRole.body),
      appearance: const AppearanceState(
        fontScale: FontScalePreference.extraLarge,
      ),
      textScale: const AccessibilityEngine().textScaleFor(
        const AppearanceState(fontScale: FontScalePreference.extraLarge),
      ),
    );
    // The declared size stays the Token's; the growth belongs to the
    // scaler — never multiplied twice.
    expect(_rendered(tester).style?.fontSize, expected);
    expect(
      tester.getSize(find.byType(MentoraText)).height,
      greaterThan(standardHeight),
    );
  });

  testWidgets('overflow is controlled by default and the line budget '
      'is honored', (tester) async {
    await _pump(
      tester,
      const SizedBox(
        width: 40,
        child: MentoraText(
          'Une phrase professionnelle bien plus longue que sa surface',
          role: MentoraTextRole.body,
          maxLines: 1,
        ),
      ),
    );

    final rendered = _rendered(tester);
    expect(rendered.overflow, TextOverflow.ellipsis);
    expect(rendered.maxLines, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selection is offered only when asked', (tester) async {
    await _pump(
      tester,
      const MentoraText('MEN-2026-0042', role: MentoraTextRole.body),
    );
    expect(find.byType(SelectableText), findsNothing);

    await _pump(
      tester,
      const MentoraText(
        'MEN-2026-0042',
        role: MentoraTextRole.body,
        selectable: true,
      ),
    );
    expect(
      find.descendant(
        of: find.byType(MentoraText),
        matching: find.byType(SelectableText),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the screen reader hears what must be heard — and never '
      'twice', (tester) async {
    final handle = tester.ensureSemantics();

    await _pump(
      tester,
      const MentoraText(
        '11h',
        role: MentoraTextRole.body,
        semanticsLabel: 'onze heures',
      ),
    );
    expect(
      tester.getSemantics(find.byType(MentoraText)).label,
      'onze heures',
    );

    await _pump(
      tester,
      const MentoraText(
        '11h',
        role: MentoraTextRole.body,
        excludeFromSemantics: true,
      ),
    );
    expect(tester.getSemantics(find.byType(MentoraText)).label, isEmpty);

    handle.dispose();
  });

  testWidgets('both reading directions are served without any special '
      'handling in the surfaces', (tester) async {
    for (final direction in TextDirection.values) {
      await _pump(
        tester,
        const MentoraText('استشارة', role: MentoraTextRole.body),
        direction: direction,
      );
      expect(tester.takeException(), isNull);
      expect(
        Directionality.of(tester.element(find.byType(MentoraText))),
        direction,
      );
    }
  });

  testWidgets('every supported locale renders through the same '
      'component — no per-language branch exists', (tester) async {
    for (final locale in LocalizationEngine.supportedLocales) {
      await _pump(
        tester,
        MentoraText(locale.languageCode, role: MentoraTextRole.body),
      );
      expect(tester.takeException(), isNull);
      expect(find.text(locale.languageCode), findsOneWidget);
    }
  });

  test('Reading Comfort is a pending contract: exactly one value is '
      'admitted today — a second one must land in the adapter', () {
    expect(
      ReadingComfortPreference.values.length,
      1,
      reason:
          'when a second reading comfort is admitted upstream, the Text '
          'Tokens Adapter must express it — never a widget',
    );
  });

  testWidgets('outside the Design Kit the text refuses to build — fail '
      'closed', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MentoraText('Consultation', role: MentoraTextRole.body),
        ),
      ),
    );
    expect(tester.takeException(), isStateError);
  });

  group('Governance — the executable scans ship with the component', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    /// The documented exemptions — each one a place whose single
    /// responsibility IS to materialize typography: the Core
    /// Components (through their adapters), the values home, the
    /// Theme Engine, and the root chrome with its own admitted 11 sp
    /// Token (outside the 27 content roles).
    bool materializesTypography(String normalized) {
      return normalized.contains('design_kit/components/') ||
          normalized.contains('design_kit/tokens/') ||
          normalized.contains('design_kit/theme/theme_engine.dart') ||
          normalized.contains('navigation/mentora_navigation_bar.dart');
    }

    test('no raw text widget survives outside the places whose job is '
        'to materialize typography', () {
      final raw = <String, RegExp>{
        'Text': RegExp(r'(?<![A-Za-z])Text\('),
        'RichText': RegExp(r'(?<![A-Za-z])RichText\('),
        'SelectableText': RegExp(r'(?<![A-Za-z])SelectableText\('),
        'TextStyle': RegExp(r'(?<![A-Za-z])TextStyle\('),
        'DefaultTextStyle': RegExp(r'(?<![A-Za-z])DefaultTextStyle\('),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final normalized = file.path.replaceAll('\\', '/');
        if (materializesTypography(normalized)) continue;
        final source = file.readAsStringSync();
        for (final entry in raw.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: only MentoraText exists — never a raw '
                '${entry.key}',
          );
        }
      }
    });

    test('no surface reads a TextTheme: the styles come from the roles, '
        'never from the ambient theme', () {
      for (final file in dartFilesOf('lib/foundation')) {
        final normalized = file.path.replaceAll('\\', '/');
        if (normalized.contains('design_kit/theme/theme_engine.dart')) {
          continue;
        }
        expect(
          file.readAsStringSync().contains('.textTheme'),
          isFalse,
          reason: '${file.path}: a role is asked, a TextTheme never is',
        );
      }
    });

    test('a Core Component never invents a style: no constructor, no '
        'weight, no size lives in the components layer', () {
      final invented = <String, RegExp>{
        'TextStyle constructor': RegExp(r'(?<![A-Za-z])TextStyle\('),
        'coded weight': RegExp(r'FontWeight\.'),
        'coded size': RegExp(r'fontSize:'),
        'coded family': RegExp(r'fontFamily:'),
      };
      final files = dartFilesOf('lib/foundation/design_kit/components');
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in invented.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: ${entry.key} — the adapter serves it',
          );
        }
      }
    });
  });
}
