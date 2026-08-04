import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/input/mentora_input.dart';
import 'package:mentora/foundation/design_kit/components/input/mentora_input_style.dart';
import 'package:mentora/foundation/design_kit/components/input/mentora_input_validator.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/input_tokens.dart';
import 'package:mentora/foundation/localization/localization_engine.dart';

/// A test judge: it publishes a verdict without the Kit ever carrying
/// a rule — the Kit never implements the port itself.
final class _RefusesOneValue implements MentoraInputValidator {
  static const String refused = 'refuse';

  const _RefusesOneValue();

  @override
  MentoraValidation validate(String value) {
    return value == refused
        ? const MentoraValidation.invalid(message: 'refusé')
        : const MentoraValidation.valid();
  }
}

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget input, {
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
          child: Scaffold(body: Center(child: input)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return services;
}

AnimatedContainer _chrome(WidgetTester tester) {
  return tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(MentoraInput),
      matching: find.byType(AnimatedContainer),
    ),
  );
}

BoxDecoration _decoration(WidgetTester tester) {
  return _chrome(tester).decoration! as BoxDecoration;
}

Color? _borderColor(WidgetTester tester) {
  final border = _decoration(tester).border;
  return border is Border ? border.bottom.color : null;
}

void main() {
  testWidgets('every chrome resolves its official surfaces and '
      'delimitations — nothing else', (tester) async {
    Future<void> check(
      MentoraInputVariant variant,
      void Function(
        ColorTokenEngine colors,
        SurfaceTokenEngine surfaces,
        BoxDecoration decoration,
      )
      verify,
    ) async {
      final services = await _pump(
        tester,
        MentoraInput(variant: variant, label: variant.name),
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

    await check(MentoraInputVariant.filled, (colors, surfaces, decoration) {
      expect(decoration.color, surface(surfaces, SurfaceRole.secondarySurface));
      expect(decoration.border, isNull);
    });
    await check(MentoraInputVariant.outlined, (colors, surfaces, decoration) {
      expect(decoration.color, surface(surfaces, SurfaceRole.primarySurface));
      expect(
        (decoration.border! as Border).top.color,
        role(colors, ColorRole.outline),
      );
    });
    await check(MentoraInputVariant.underlined, (colors, surfaces, decoration) {
      expect(decoration.color, isNull);
      final border = decoration.border! as Border;
      // A base alone: the underline delimits, the sides never do.
      expect(border.bottom.color, role(colors, ColorRole.outline));
      expect(border.top.style, BorderStyle.none);
      expect(decoration.borderRadius, isNull);
    });
    await check(MentoraInputVariant.search, (colors, surfaces, decoration) {
      expect(decoration.color, surface(surfaces, SurfaceRole.secondarySurface));
      expect(
        decoration.borderRadius,
        BorderRadius.circular(inputSearchCornerRadius),
      );
    });
    await check(MentoraInputVariant.secure, (colors, surfaces, decoration) {
      expect(decoration.color, surface(surfaces, SurfaceRole.primarySurface));
    });
  });

  testWidgets('availability is orthogonal to the chrome: a search '
      'field stays a search field when it is read-only', (tester) async {
    final services = await _pump(
      tester,
      const MentoraInput(
        variant: MentoraInputVariant.search,
        availability: MentoraInputAvailability.readOnly,
        label: 'recherche',
      ),
    );

    // The chrome keeps its rounded affordance…
    expect(
      _decoration(tester).borderRadius,
      BorderRadius.circular(inputSearchCornerRadius),
    );
    // …while the availability moves it to the resting surface.
    expect(
      _decoration(tester).color,
      services.get<SurfaceTokenEngine>().surfaceOf(
        SurfaceRole.secondarySurface,
        ThemeVariantId.light,
      ),
    );
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
  });

  testWidgets('read-only is not unavailable: the value stays fully '
      'readable, only the writing is closed', (tester) async {
    final controller = TextEditingController(text: 'MEN-2026');
    addTearDown(controller.dispose);
    final services = await _pump(
      tester,
      MentoraInput(
        availability: MentoraInputAvailability.readOnly,
        textController: controller,
      ),
    );

    expect(find.byType(Opacity), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).style?.color,
      services.get<ColorTokenEngine>().colorOf(
        ColorRole.foreground,
        ThemeVariantId.light,
      ),
    );
  });

  testWidgets('disabled is stated, never hidden: the official veil and '
      'the unavailable role', (tester) async {
    final services = await _pump(
      tester,
      const MentoraInput(
        availability: MentoraInputAvailability.disabled,
        label: 'indisponible',
      ),
    );

    final opacity = tester.widget<Opacity>(
      find
          .descendant(
            of: find.byType(MentoraInput),
            matching: find.byType(Opacity),
          )
          .first,
    );
    expect(opacity.opacity, inputDisabledVeilOpacity);
    expect(find.text('indisponible'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).style?.color,
      services.get<ColorTokenEngine>().colorOf(
        ColorRole.unavailable,
        ThemeVariantId.light,
      ),
    );
  });

  testWidgets('the focus delimits with the focus role at the ring '
      'width', (tester) async {
    final services = await _pump(tester, const MentoraInput(label: 'nom'));

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(
      _borderColor(tester),
      services.get<ColorTokenEngine>().colorOf(
        ColorRole.focus,
        ThemeVariantId.light,
      ),
    );
    expect(
      (_decoration(tester).border! as Border).bottom.width,
      inputFocusRingWidth,
    );
  });

  testWidgets('typing carries the value, and the placeholder steps '
      'aside as soon as something is written', (tester) async {
    var seen = '';
    await _pump(
      tester,
      MentoraInput(placeholder: 'votre nom', onChanged: (v) => seen = v),
    );
    expect(find.text('votre nom'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Awa');
    await tester.pumpAndSettle();

    expect(seen, 'Awa');
    expect(find.text('votre nom'), findsNothing);
  });

  testWidgets('a refusal is never hidden by the focus — the critical '
      'delimitation survives the ring', (tester) async {
    final services = await _pump(
      tester,
      const MentoraInput(
        label: 'nom',
        validator: _RefusesOneValue(),
        placeholder: 'votre nom',
      ),
    );
    final critical = services.get<ColorTokenEngine>().colorOf(
      ColorRole.critical,
      ThemeVariantId.light,
    );

    await tester.enterText(find.byType(TextField), _RefusesOneValue.refused);
    await tester.pumpAndSettle();

    // The field is focused after typing, and still shows the refusal.
    expect(_borderColor(tester), critical);
    expect(find.text('refusé'), findsOneWidget);
  });

  testWidgets('the published verdict wins over the local one — an '
      'announced decision is never overwritten by a keystroke', (tester) async {
    final controller = MentoraInputController();
    addTearDown(controller.dispose);
    final services = await _pump(
      tester,
      MentoraInput(
        label: 'nom',
        controller: controller,
        validator: const _RefusesOneValue(),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Awa');
    controller.publishValidation(
      const MentoraValidation.invalid(message: 'déjà utilisé'),
    );
    await tester.pumpAndSettle();

    expect(find.text('déjà utilisé'), findsOneWidget);
    expect(
      _borderColor(tester),
      services.get<ColorTokenEngine>().colorOf(
        ColorRole.critical,
        ThemeVariantId.light,
      ),
    );
  });

  testWidgets('the announced phases are expressed: loading closes the '
      'writing, success and error speak their roles', (tester) async {
    final controller = MentoraInputController();
    addTearDown(controller.dispose);
    final services = await _pump(
      tester,
      MentoraInput(label: 'nom', controller: controller),
    );
    Color role(ColorRole r) =>
        services.get<ColorTokenEngine>().colorOf(r, ThemeVariantId.light);

    controller.beginLoading();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).readOnly,
      isTrue,
      reason: 'a pending field is never written into',
    );

    controller.showSuccess();
    await tester.pumpAndSettle();
    expect(_borderColor(tester), role(ColorRole.success));

    controller.showError();
    await tester.pumpAndSettle();
    expect(_borderColor(tester), role(ColorRole.critical));

    controller.reset();
    await tester.pumpAndSettle();
    expect(_borderColor(tester), role(ColorRole.outline));
  });

  testWidgets('the opposable reachable target prevails at every size', (
    tester,
  ) async {
    for (final size in MentoraInputSize.values) {
      await _pump(tester, MentoraInput(size: size));
      expect(
        tester.getSize(find.byType(AnimatedContainer)).height,
        greaterThanOrEqualTo(48),
      );
    }
  });

  testWidgets('a secure field obscures, and reveals only through a '
      'named affordance — an unnamed control is never rendered', (
    tester,
  ) async {
    await _pump(
      tester,
      const MentoraInput(variant: MentoraInputVariant.secure, label: 'code'),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isTrue,
    );
    expect(find.byType(InkWell), findsNothing);

    await _pump(
      tester,
      const MentoraInput(
        variant: MentoraInputVariant.secure,
        label: 'code',
        secureRevealLabel: 'afficher',
      ),
    );
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isFalse,
    );
  });

  testWidgets('every duration comes from the Motion Engine: writing is '
      'accompanied, a refusal attracts, None silences both', (tester) async {
    const appearance = AppearanceState();
    final services = await _pump(tester, const MentoraInput(label: 'nom'));
    final motion = services.get<MotionEngine>();
    expect(
      _chrome(tester).duration,
      motion.durationFor(MotionIntention.accompagner, appearance),
    );

    await _pump(
      tester,
      const MentoraInput(label: 'nom', validator: _RefusesOneValue()),
    );
    await tester.enterText(find.byType(TextField), _RefusesOneValue.refused);
    await tester.pumpAndSettle();
    expect(
      _chrome(tester).duration,
      motion.durationFor(MotionIntention.attirerLAttention, appearance),
    );

    await _pump(
      tester,
      const MentoraInput(label: 'nom'),
      appearance: const AppearanceState(motion: MotionPreference.none),
    );
    expect(_chrome(tester).duration, Duration.zero);
  });

  testWidgets('the four theme variants serve the same roles — high '
      'contrast included', (tester) async {
    for (final variant in ThemeVariantId.values) {
      final services = await _pump(
        tester,
        const MentoraInput(label: 'nom'),
        variant: variant,
      );
      expect(
        _borderColor(tester),
        services.get<ColorTokenEngine>().colorOf(ColorRole.outline, variant),
      );
    }
  });

  testWidgets('both directions and every official locale are served — '
      'no screen ever handles them specially', (tester) async {
    for (final direction in TextDirection.values) {
      await _pump(
        tester,
        const MentoraInput(label: 'الاسم', placeholder: 'اكتب هنا'),
        direction: direction,
      );
      await tester.enterText(find.byType(TextField), 'استشارة');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('استشارة'), findsOneWidget);
    }

    for (final locale in LocalizationEngine.supportedLocales) {
      await _pump(tester, MentoraInput(label: locale.languageCode));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('the field announces itself: a named text field, its '
      'value, its obscurity and its availability', (tester) async {
    final handle = tester.ensureSemantics();

    await _pump(
      tester,
      const MentoraInput(label: 'Nom', placeholder: 'votre nom'),
    );
    await tester.enterText(find.byType(TextField), 'Awa');
    await tester.pumpAndSettle();
    final node = tester.getSemantics(find.byType(MentoraInput));
    expect(node.label, contains('Nom'));
    expect(node.value, contains('Awa'));

    await _pump(
      tester,
      const MentoraInput(
        variant: MentoraInputVariant.secure,
        label: 'Code',
        semanticLabel: 'Code secret',
      ),
    );
    final secure = tester.getSemantics(find.byType(MentoraInput));
    expect(secure.label, contains('Code secret'));
    expect(secure.value, isEmpty, reason: 'an obscured value is never read');

    handle.dispose();
  });

  testWidgets('autofill and the keyboard type reach the platform '
      'untouched', (tester) async {
    await _pump(
      tester,
      const MentoraInput(
        label: 'Courriel',
        keyboardType: TextInputType.emailAddress,
        autofillHints: [AutofillHints.email],
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.keyboardType, TextInputType.emailAddress);
    expect(field.autofillHints, contains(AutofillHints.email));
  });

  testWidgets('the keyboard reaches the field: focus travels and text '
      'is entered without a pointer', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await _pump(tester, MentoraInput(label: 'nom', focusNode: focus));

    focus.requestFocus();
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('the Kit carries validation states, never a rule', () {
    // The port exists; the Kit implements none of it.
    expect(MentoraValidation.pristine.state, MentoraValidationState.pristine);
    expect(const MentoraValidation.invalid(message: 'x').isInvalid, isTrue);
    expect(const MentoraValidation.valid().message, isNull);
  });

  testWidgets('outside the Design Kit the field refuses to build — '
      'fail closed', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MentoraInput())),
    );
    expect(tester.takeException(), isStateError);
  });

  group('Governance — the executable scans ship with the component', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    test('no raw field widget survives outside the Input component', () {
      final raw = <String, RegExp>{
        'TextField': RegExp(r'(?<![A-Za-z])TextField\('),
        'TextFormField': RegExp(r'(?<![A-Za-z])TextFormField\('),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final normalized = file.path.replaceAll('\\', '/');
        if (normalized.contains('components/input/')) continue;
        final source = file.readAsStringSync();
        for (final entry in raw.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: only MentoraInput exists — never a raw '
                '${entry.key}',
          );
        }
      }
    });

    test('no InputDecoration exists anywhere in the foundation: the '
        'component owns its chrome', () {
      final forbidden = <String, RegExp>{
        'InputDecoration': RegExp(r'(?<![A-Za-z])InputDecoration\('),
        'OutlineInputBorder': RegExp(r'(?<![A-Za-z])OutlineInputBorder\('),
        'UnderlineInputBorder': RegExp(r'(?<![A-Za-z])UnderlineInputBorder\('),
        'InputBorder.none': RegExp(r'InputBorder\.none'),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: ${entry.key} has no place in Mentora',
          );
        }
      }
    });

    test('a Core Component never reads the ambient theme: everything '
        'comes through the scope', () {
      for (final file in dartFilesOf('lib/foundation')) {
        expect(
          RegExp(r'Theme\.of\(').hasMatch(file.readAsStringSync()),
          isFalse,
          reason: '${file.path}: the scope serves, the ambient theme does not',
        );
      }
    });

    test('no form, breathing or delimitation is coded outside the '
        'tokens layer', () {
      final coded = <String, RegExp>{
        'coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'coded padding': RegExp(r'EdgeInsets\.\w+\(\s*[0-9]'),
        'coded border width': RegExp(r'width:\s*[0-9]+(\.[0-9]+)?\s*\)'),
        'coded elevation': RegExp(r'elevation:\s*[0-9]'),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final normalized = file.path.replaceAll('\\', '/');
        if (normalized.contains('design_kit/tokens/')) continue;
        final source = file.readAsStringSync();
        for (final entry in coded.entries) {
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
